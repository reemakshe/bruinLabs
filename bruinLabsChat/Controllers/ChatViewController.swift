//
//  ChatViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/27/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import MessageKit

struct Message : MessageType {
    var sender: SenderType

    var messageId: String

    var sentDate: Date

    var kind: MessageKind

}

struct Sender : SenderType {
//    var photoURL: String
    var senderId: String
    var displayName: String


}

class ChatViewController: MessagesViewController {

    private var messages = [Message]()

    private let selfSender = Sender(senderId: "1", displayName: "Joe Smith")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world message")))

         messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world message. Hello world message. hello world message. hello world message")))

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

    }


}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return selfSender
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
