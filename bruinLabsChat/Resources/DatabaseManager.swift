//
//  DatabaseManager.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/27/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(email : String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public func userExists(with email: String, completion : @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        print(safeEmail)
        
        database.child("users").child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value)
                completion(true)
                return
            }
            //            print("user does not exist")
            completion(false)
        }
        
    }
    
    public func insertUser(with user: ChatAppUser)
    {
        database.child("users").child(user.safeEmail).setValue(["username" : user.username, "state" : user.state, "fun_fact" : user.funfact])
        database.child(user.safeEmail).child("username").setValue(user.username)
    }
    
    public func createGroup(with group: NewGroup, completion: @escaping (Bool) -> Void)
    {
        for tag in group.tags {
            database.child("groups").child(group.safeName).child("tags").child(tag).setValue("true", withCompletionBlock: {error, _ in
                guard error == nil else {
                    print("failed to write to database")
                    completion(false)
                    return
                }
            })
            print("adding tags: \(tag)\n")
        }
        
        
        let currentUser = Auth.auth().currentUser
        let currEmail = currentUser!.email
        var currsafeEmail = currEmail!.replacingOccurrences(of: "@", with: "-")
        currsafeEmail = currsafeEmail.replacingOccurrences(of: ".", with: "-")
        
        var username : String = ""
        
        database.child("users").child(currsafeEmail).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            username = snapshot.value as! String
            self.database.child("groups").child(group.safeName).child("members").child(currsafeEmail).setValue(username, withCompletionBlock: {error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
            })
            print("username  \(username)")
        }
        
        print("username \(username)")
        
        
        //        database.child("groups").child(group.safeName).child("members").child(currsafeEmail).setValue(username, withCompletionBlock: {error, _ in
        //            guard error == nil else {
        //                completion(false)
        //                return
        //            }
        //        })
        
        
        //        database.child("groups").child(group.safeName).child("names").setValue([username: true]) { (error, _) in
        //            guard error == nil else {
        //                completion(false)
        //                return
        //            }
        //        }
        database.child("users").child(currsafeEmail).child("groups").child(group.safeName).setValue(true, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
            }
        })
        
        completion(true)
        
    }
    
    
    public func groupAlreadyExists(with name: String, completion : @escaping ((Bool) -> Void))
    {
        database.child("groups").child(name).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                print(snapshot.value)
                completion(true)
                return
            }
            //            print("user does not exist")
            completion(false)
        }
        
    }
    /*
     array of group names
     group name dictionary to (two more dictionaries)
     [String : [String : [String], String : [String]]]
     */
    //    [String : [String : [String : Bool]]
    public func getAllUsers(completion : @escaping (Result<[String : [String : [String : String]]], Error>) -> Void) {
        database.child("groups").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String : [String : [String : String]]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                print(type(of: snapshot.value))
                print(snapshot.value!)
                return
            }
            completion(.success(value))
            print(value)
            print("successfully fetched data")
        }
    }
    
    public enum DatabaseErrors : Error {
        case failedToFetch
    }
}


extension DatabaseManager {
//    public func createNewGroupConvo(group : String, creator : String, completion : @escaping (Bool) -> Void)
//    {
//        let conversationId = "conversation_\(group)"
//
//        var convos : [[String : Any]]
//        let convo = [
//            "id" : conversationId,
////            "latest_message" : [
////                "date" : dateString,
////                "is_read" : false,
////                "message" : message,
////            ],
//            "users" : [[creator : self.getUsername(email: creator)]],
//            "name" : group
//        ] as [String : Any]
//        convos.append(convo)
//        database.child(creator).child("conversations").setValue(convos) { (error, _) in
//            if error == nil {
//                completion(false)
//                print("group could not be added to database")
//                return
//            }
//            completion(true)
//        }
//
//
//
//        database.child(conversationId).child("messages")
//    }
//
//    func userJoinedGroup(userEmail : String, groupName: String) {
//        database.child(userEmail).child("conversations").observeSingleEvent(of: .value) { (snapshot) in
//            //add conversation id and data to user
//        }
//    }
    
    public func createNewConversation(group : String, with otherUsers: [String : String], firstMessage : Message, completion : @escaping (Bool) -> Void) {
        guard let currentEmail = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind
        {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
        
        let conversationId = "conversation_\(firstMessage.messageId)"
        
        var conversationData = [
            "id" : "conversation_\(firstMessage.messageId)",
            "latest_message" : [
                "date" : dateString,
                "is_read" : false,
                "message" : message,
                "other_users" : otherUsers
            ],
            "name" : group
            ] as [String : Any]
        
        var doesConvoExist = false
        
        for (user, _) in otherUsers {
            var otherConversationData = conversationData
            //            otherConversationData["sender_email"] = user
            
            let otherRef = self.database.child("\(user)")
            otherRef.observeSingleEvent(of: .value) { (snapshot) in
                guard var otherUserNode = snapshot.value as? [String : Any] else {
                    completion(false)
                    print("user not found")
                    return
                }
                
                if var conversations = otherUserNode["conversations"] as? [[String : Any]] {
                    //conversation array exists for user
                    doesConvoExist = true
                    conversations.append(conversationData)
                    otherUserNode["conversations"] = conversations
                    otherRef.setValue(otherUserNode) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            print("could not append conversation data")
                            return
                        }
                    }
                }
                else {
                    self.database.child(user).child("conversations").setValue([conversationData])
                }
            }
            if !doesConvoExist {
                self.finishCreatingConversation(users: otherUsers, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
            }
            
            //            self.database.child(user).child("conversations").setValue([conversationData])
        }
        
    }

    private func finishCreatingConversation(users: [String : String], conversationID: String, firstMessage: Message, completion : @escaping (Bool) -> Void) {
        
        var message_content = ""
        
        switch firstMessage.kind
        {
            
        case .text(let messageText):
            message_content = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
        
        let currentUserEmail =  DatabaseManager.safeEmail(email: (FirebaseAuth.Auth.auth().currentUser?.email)!)
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        let message = [
            "id": firstMessage.messageId,
            "type" : "text",
            "content" : message_content,
            "date" : dateString,
            "sender_email" : currentUserEmail,
            "name" : users[currentUserEmail],
            "is_read": false
            ] as [String : Any]
        let value = [
            "messages" : [message]
        ]
        database.child(conversationID).setValue(value) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }

    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void)
    {
        database.child(email).child("conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                print("failed to get conversations from database")
                return
            }
            
            let conversations: [Conversation] = value.compactMap({  dictionary in
                let conversationId = dictionary["id"] as! String
                let latestMessage = dictionary["latest_message"] as! [String : Any]
                let date = latestMessage["date"] as! String
                let is_read = latestMessage["is_read"] as! Bool
                let message = latestMessage["message"] as! String
                let other_users = latestMessage["other_users"] as! [String : String]
                let name = dictionary["name"] as! String
                //                        print("could not make into compact map")
                //                        print("dictionary \(dictionary)")
                //                        print("conversation id \(dictionary["id"])")
                //                        return nil
                
                
                print("conversationid \(conversationId)")
                
                let latestMessageObject = LatestMessage(date: date, text: message, is_read: is_read)
                
                
                return Conversation(id: conversationId, name: name, other_users: other_users, latest_message: latestMessageObject)
            })
            
            print(conversations)
            
            completion(.success(conversations))
            
        }
        
    }
    
    public func getAllMessages(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child(id).child("messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                print("failed to get conversations from database")
                return
            }
            
            
            let messages: [Message] = value.compactMap({  dictionary in
                
                print(dictionary)
                let email = dictionary["sender_email"] as! String
                let name = dictionary["name"] as! String
                let is_read = dictionary["is_read"] as! Bool
                let messageId = dictionary["id"] as! String
                let content = dictionary["content"] as! String
                let senderEmail = dictionary["sender_email"] as! String
                let dateString = dictionary["date"] as! String
                
                let date = ChatViewController.dateFormatter.date(from: dateString)
                let sender = Sender(senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageId, sentDate: date!, kind: .text(content))
                
            })
            
            
            completion(.success(messages))
            
        }
    }
    
    public func sendMessage(to conversation: String, message : Message, completion: @escaping (Bool) -> Void)
    {
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String : Any]] else {
                completion(false)
                return
            }
            
            var message_content = ""
            
            switch message.kind
            {
                
            case .text(let messageText):
                message_content = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            }
            
            let currentUserEmail =  DatabaseManager.safeEmail(email: (FirebaseAuth.Auth.auth().currentUser?.email)!)
            
            let messageDate = message.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            let newMessage = [
                "id": message.messageId,
                "type" : "text",
                "content" : message_content,
                "date" : dateString,
                "sender_email" : currentUserEmail,
                "name" : strongSelf.getUsername(email: currentUserEmail),
                "is_read": false
                ] as [String : Any]
            
            currentMessages.append(newMessage)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { (error, _) in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
        
    }
    
    public func getUsername(email: String) -> String {
        print("getting username")
        var value = ""
        database.child(email).child("username").observe(.value) { (snapshot) in
            if snapshot.exists() {
                value = snapshot.value as! String
            }
        }
        return value
        
    }
    
    
}

struct ChatAppUser {
    let username: String
    let email: String
    let state: String
    let funfact: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
        
    }
    
    //    var profilePicUrl : String {
    //        return "\(safeEmail)_profile_picture.png"
    //    }
}

struct NewGroup {
    let name : String
    var safeName : String {
        let safeName = name.replacingOccurrences(of: " ", with: "-")
        return safeName
    }
    let tags : [String]
}



//, withCompletionBlock: { error, _ in
//    guard error == nil else {
//        completion(false)
//        return
//    }
//    completion(true)
//}


