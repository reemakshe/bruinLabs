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
        database.child("users").child(user.safeEmail).child("username").setValue(user.username)
        database.child(user.safeEmail).child("username").setValue(user.username)
    }
    
    
    public func insertGoals(email: String, goals: [String]) {
        database.child("users").child(email).child("goals").setValue(goals)
    }
    
    
    public func getAllUsers(completion : @escaping (Result<[[String : String]], Error>) -> Void) {
        var results = [[String : String]]()
        //        var usersEmails = [String]()
        //        var usernames = [String]()
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            //            [String : [String : String]]
            guard let value = snapshot.value as? [String : [String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                print(type(of: snapshot.value))
                print(snapshot.value!)
                return
            }
            
            print("values: \(value)")
            for (user, data) in value {
                let username = data["username"] as! String
                results.append(["name" : username, "email" : user])
//                results.append(["email" : user])
            }
            
            completion(.success(results))
            print("fetched user results \(results)")
            print("successfully fetched data")
        }
    }
    
    public func getAllUsersGoals(completion : @escaping (Result<[[String : Any]], Error>) -> Void) {
        var results = [[String : Any]]()
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        var currentUserData = [String : Any]()
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String : [String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                print("could not get snapshot of goals")
                return
            }
            
            for (user, data) in value {
                if user == safeEmail {
                    currentUserData["username"] = data["username"]
                    currentUserData["email"] = user
                    currentUserData["goals"] = data["goals"] as! [String]
//                    print("current user goals: \(data["goals"])")
                    continue
                }
                let username = data["username"] as! String
                let goals = data["goals"] as! [String]
                results.append(["username": username, "email": user, "goals" : goals])
            }
            
            var sortedUsers = [[String : Any]]()
            let currentUserGoals = currentUserData["goals"] as! [String]
            for entry in results {
                let user = entry["email"] as! String
                let goals = entry["goals"] as! [String]
                let username = entry["username"]
                var matchTotal = 0
                for goal in goals {
                    if currentUserGoals.contains(goal) {
                        matchTotal += 1
                    }
                }
                sortedUsers.append(["email" : user, "match" : matchTotal, "goals" : goals, "username" : username])
            }
            
            print("matches before sorting : \(sortedUsers)")
            
            sortedUsers.sort {
                (($0 as! [String : Any])["match"] as! Int) > (($1 as! [String : Any])["match"] as! Int)
            }
            
            print("matches after sorting : \(sortedUsers)")
//            sortedUsers = sortedUsers.s
            
            completion(.success(sortedUsers))
            print("successfully got all users with goals")
        }
    }
    
    public enum DatabaseErrors : Error {
        case failedToFetch
    }
}


extension DatabaseManager {
    
    public func createNewConversation(otherUserName: String, otherUserEmail : String, firstMessage : Message, completion : @escaping (Bool) -> Void) {
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
            "recipient_id" : otherUserEmail,
            "recipient_name" : otherUserName,
            "latest_message" : [
                "date" : dateString,
                "is_read" : false,
                "message" : message
            ],
            //            "name" : "name"
            ] as [String : Any]
        
        var recipientConversationData = [
            "id" : "conversation_\(firstMessage.messageId)",
            "recipient_id" : otherUserEmail,
            "recipient_name" : otherUserName,
            "latest_message" : [
                "date" : dateString,
                "is_read" : false,
                "message" : message
            ],
            //            "name" : "name"
            ] as [String : Any]
        
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard var userNode = snapshot.value as? [String : Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            print("user node snapshot value \(snapshot.value)")
            
            if var conversations = userNode["conversations"] as? [[String : Any]] {
                //conversation exists between users
                print("conversations already exist")
                conversations.append(conversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else {
                        completion(false)
                        print("did not add conversation data")
                        return
                    }
                    self?.finishCreatingConversation(otherUserName: otherUserName, conversationID: conversationId, firstMessage: firstMessage, completion: completion)                               }
            }
                
            else {
                //conversations does not exist between users yet
                //                self.database.child(safeEmail).child("conversations").setValue([conversationData])
                print("conversations do not exist for this user")
                userNode["conversations"] = [conversationData]
                ref.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else {
                        completion(false)
                        print("did not add conversation data")
                        return
                    }
                    self?.finishCreatingConversation(otherUserName: otherUserName, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
        }
        
        database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if var conversations = snapshot.value as? [[String : Any]] {
                //recipient has convos already
                conversations.append(recipientConversationData)
                self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
            }
            else {
                self?.database.child("\(otherUserEmail)/conversations").setValue([recipientConversationData])
            }
        }
        
        
    }
    
    private func finishCreatingConversation(otherUserName: String, conversationID: String, firstMessage: Message, completion : @escaping (Bool) -> Void) {
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
            "recipient_name" : otherUserName,
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
        database.child("\(email)/conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                print("failed to get conversations from database")
                return
            }
            
            let conversations: [Conversation] = value.compactMap({  dictionary in
                guard let conversationId = dictionary["id"] as? String else {
                    print("unable to make conversation")
                    return nil
                }
                guard let latestMessage = dictionary["latest_message"] as? [String : Any] else {
                    print("unable to make latest message")
                    return nil
                }
                guard let date = latestMessage["date"] as? String else {
                    print("unable to make date")
                    return nil
                }
                guard let is_read = latestMessage["is_read"] as? Bool else {
                    print("unable to make is red")
                    return nil
                }
                guard let message = latestMessage["message"] as? String else {
                    print("unable to make message content")
                    return nil
                }
                guard let other_user_email = dictionary["recipient_id"] as? String else {
                    print("unable to make other_user_enai")
                    return nil
                }
                guard let name = dictionary["recipient_name"] as? String else {
                        print("not able to make into compact map")
                        return nil
                }
                
                print("conversationid \(conversationId)")
                
                let latestMessageObject = LatestMessage(date: date, text: message, is_read: is_read)
                
                
                return Conversation(id: conversationId, name: name, other_user_email: other_user_email, latest_message: latestMessageObject)
            })
            
            print("conversatione fetched \(conversations)")
            
            completion(.success(conversations))
            
        }
        
    }
    
    public func getAllMessages(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String : Any]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                print("failed to get conversations from database")
                return
            }
            
            
            let messages: [Message] = value.compactMap({  dictionary in
                
                print(dictionary)
                guard let email = dictionary["sender_email"] as? String,
                    let name = dictionary["recipient_name"] as? String,
                    let is_read = dictionary["is_read"] as? Bool,
                    let messageId = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let dateString = dictionary["date"] as? String else {
                        print("could not make messages into compact map")
                        return nil
                }
                
                let date = ChatViewController.dateFormatter.date(from: dateString)
                let sender = Sender(senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageId, sentDate: date!, kind: .text(content))
                
            })
            
            
            completion(.success(messages))
            
        }
    }
    
    public func sendMessage(otherUserEmail: String, conversationId: String, message : Message, completion: @escaping (Bool) -> Void)
    {
        
        guard let currentEmail = (FirebaseAuth.Auth.auth().currentUser?.email) as? String else {
            completion(false)
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        //add new message
        self.database.child("\(conversationId)/messages").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String : Any]] else {
                print("getting current messages for this convo failed")
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
                "recipient_name" : strongSelf.getUsername(email: otherUserEmail),
                "is_read": false
                ] as [String : Any]
            
            currentMessages.append(newMessage)
            strongSelf.database.child("\(conversationId)/messages").setValue(currentMessages) { (error, _) in
                guard error == nil else {
                    print("error adding new message to databse")
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(safeEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                    guard var currentUserConversations = snapshot.value as? [[String : Any]] else {
                        print("unable to get current convos to update latest message")
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String : Any] = [
                        "date":dateString,
                        "is_read":false,
                        "message":message_content
                    ]
                    
                    var position = 0
                    
                    var targetConversation : [String : Any]?
                    
                    for conversation in currentUserConversations {
                        if let currentId = conversation["id"] as? String, currentId == conversationId {
                            targetConversation = conversation
                            break
                        }
                         position += 1
                    }
                    print("target conversation before update: \(targetConversation)")
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    print("updated target conversation: \(finalConversation)")
                    currentUserConversations[position] = finalConversation
                    strongSelf.database.child("\(safeEmail)/conversations").setValue(currentUserConversations) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
                
                strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                    guard var otherUserConversations = snapshot.value as? [[String : Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String : Any] = [
                        "date":dateString,
                        "is_read":false,
                        "message":message_content
                    ]
                    
                    var position = 0
                    
                    var targetConversation : [String : Any]?
                    
                    for conversation in otherUserConversations {
                        if let currentId = conversation["id"] as? String, currentId == conversationId {
                            targetConversation = conversation
                            break
                        }
                         position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    otherUserConversations[position] = finalConversation
                    strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
                
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
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
        
    }
    
    let goals : [String]
//    let profile_pic = "\(safeEmail)_profile_picture.png"
    
    var profilePicUrl : String {
            return "\(safeEmail)_profile_picture.png"
    }
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


