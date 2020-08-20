//
//  ChatViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/27/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseAuth
import InputBarAccessoryView

struct Message : MessageType {
    public var sender: SenderType

    public var messageId: String

    public var sentDate: Date

    public var kind: MessageKind

}

//extension MessageKind {
//    var description : String {
//        
//    }
//}

struct Sender : SenderType {
    public var senderId: String
    public var displayName: String


}


class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    
    private let otherUserEmails : [String]
    private let otherUserNames : [String]
    
    private var currentUserProfileUrl : URL?
    private var otherUserProfileUrl : URL?
    
    var conversationid : String?

    private var messages = [Message]()

    private var selfSender: Sender? {
        let email = DatabaseManager.safeEmail(email: (FirebaseAuth.Auth.auth().currentUser?.email)!)
        if email.isEmpty {
            print("current user is nil")
            return nil
        }
        
        return Sender(senderId: email, displayName: "me")
        
    }
    
    private func listenForMessages(id : String) {
        
        DatabaseManager.shared.getAllMessages(with: id) { [weak self] (result) in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    self?.messagesCollectionView.scrollToLastItem()
                }
            case .failure(let error):
                print("failed to fetch messages \(error)")
            }
        }
    }
    
    init(otherUser: [String], otherNames: [String], id: String?) {
            self.otherUserEmails = otherUser
            self.otherUserNames = otherNames
    //        self.group = group_name
            self.conversationid = id
            super.init(nibName: nil, bundle: nil)

        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditButton))
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    
    @objc private func didTapEditButton() {
        let vc = GroupInfoViewController(otherEmails: otherUserEmails, otherNames: otherUserNames, conv_id: conversationid!, chat: self)
        
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    public func changeChatTitle(name : String) {
        self.title = name
    }
    
    override func viewDidAppear(_ animated: Bool) {
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationid {
            self.listenForMessages(id: conversationId)
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(displayP3Red: 0.5058, green: 0.7569, blue: 0.7569, alpha: 1) : UIColor(displayP3Red: 0.835, green: 0.835, blue: 0.835, alpha: 1)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        
        if sender.senderId == selfSender?.senderId {
            //show our image
            if let currentUserImage = self.currentUserProfileUrl {
                avatarView.sd_setImage(with: currentUserImage, completed: nil)
            }
            else {
                //fetch url
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let safeEmail = DatabaseManager.safeEmail(email: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        self?.currentUserProfileUrl = url
                    case .failure(let error):
                        print("failed to fetch url \(error)")
                    }
                }
            }
        }
        else {
            //show other image
            if let otherUserImage = self.otherUserProfileUrl {
                avatarView.sd_setImage(with: otherUserImage, completed: nil)
            }
            else {
                //fetch url
                let otherUserId = sender.senderId
//                let path = "images/\(otherUserEmail)_profile_picture.png"
                let path = "images/\(otherUserId)_profile_picture.png"
                StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
                    switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        self?.otherUserProfileUrl = url
                    case .failure(let error):
                        print("failed to fetch url \(error)")
                    }
                }
            }
        }
    }


}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
            guard !text.replacingOccurrences(of: " ", with: "").isEmpty  else {
                print("message is empty")
                return
            }
            
            guard let selfSender = self.selfSender else {
                print("sender doesnt exist")
                return
            }
            
            guard let messageId = createMessageId() else {
                print("message id not created")
                return
            }
            
            print("Sending: \(text)")
            
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            inputBar.inputTextView.text = ""
            
            if isNewConversation {
                print("in new conversation block")
                DatabaseManager.shared.createNewConversation(otherUserNames : self.otherUserNames, otherUserEmails: otherUserEmails, firstMessage: message) { [weak self] (success) in
                    if success {
                        print("Message sent")
                        self?.isNewConversation = false
                        
                        let newConversationId = "conversation_\(message.messageId)"
                        self?.conversationid = newConversationId
                        self?.listenForMessages(id: newConversationId)
                    }
                    else {
                        print("message failed to send")
                    }
                }
            }
            
            else {
                print("in existing conversation block")
                DatabaseManager.shared.sendMessage(otherUserEmails: otherUserEmails, otherUserNames: otherUserNames, conversationId: self.conversationid!, message: message) { [weak self] (success) in
                    if success {
                        print("Message sent")
                        DispatchQueue.main.async {
                            self?.messagesCollectionView.reloadDataAndKeepOffset()
                            //                    self?.messagesCollectionView.scrollToBottom(animated: false)
                            self?.messagesCollectionView.scrollToLastItem()
                        }
                    }
                    else {
                        print("message failed to send")
                    }
                }
            }
        }
        
    
    private func createMessageId() -> String? {
        //date, senderemail, first other member email, randomInt
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = FirebaseAuth.Auth.auth().currentUser?.email else {
            return nil
        }
        let newIdentifier = "\(otherUserEmails[0])_\(dateString)_\(DatabaseManager.safeEmail(email: currentUserEmail))"
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }


}
