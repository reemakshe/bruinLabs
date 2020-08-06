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
//    var photoURL: String
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
    public let otherUserEmail : String
    
//    public var otherMembers : [String : String]
    
//    public var group : String
    
    let conversationid : String?

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
//        if (id == "") {
//            return
//        }
        
        DatabaseManager.shared.getAllMessages(with: id) { [weak self] (result) in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    self?.messagesCollectionView.scrollToBottom()

                }
            case .failure(let error):
                print("failed to fetch messages \(error)")
            }
        }
    }
    
    
    init(otherUser: String, id: String?) {
        self.otherUserEmail = otherUser
//        self.group = group_name
        self.conversationid = id
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(displayP3Red: 0.843, green: 0.925, blue: 0.925, alpha: 1)

//        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world message")))
//
//         messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world message. Hello world message. hello world message. hello world message")))

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
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
        
        if isNewConversation {
            print("in new conversation block")
            DatabaseManager.shared.createNewConversation(otherUserName: self.title ?? "user", otherUserEmail: otherUserEmail, firstMessage: message) { [weak self] (success) in
                if success {
                    print("Message sent")
                    self?.isNewConversation = false
                }
                else {
                    print("message failed to send")
//                    DatabaseManager.shared.sendMessage(otherUserEmail: self.otherUserEmail, conversation: (self?.conversationid)!, message: message) { (success) in
//                        if success {
//                            print("message sent")
//                        }
//                        else {
//                            print("message failed to send")
//                        }
//                    }
                }
            }
        }
        
        else {
            print("in existing conversation block")
            DatabaseManager.shared.sendMessage(otherUserEmail: otherUserEmail, conversationId: self.conversationid!, message: message) { (success) in
                if success {
                    print("Message sent")
                }
                else {
                    print("message failed to send")
//                    DatabaseManager.shared.sendMessage(otherUserEmail: self.otherUserEmail, conversation: (self.conversationid)!, message: message) { (success) in
//                        if success {
//                            print("message sent")
//                        }
//                        else {
//                            print("message failed to send")
//                        }
//                    }
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
        let newIdentifier = "\(otherUserEmail)_\(dateString)_\(DatabaseManager.safeEmail(email: currentUserEmail))"
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


//import UIKit
//
//class ChatViewController : UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .red
//
//        }
//
//}
