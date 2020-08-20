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
    
    
    public func getAllUsers(completion : @escaping (Result<[[String : Any]], Error>) -> Void) {
        var results = [[String : Any]]()
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
                let goals = data["goals"] as! [String]
                results.append(["name" : username, "email" : user, "goals" : goals])
                //                results.append(["email" : user])
            }
            
            completion(.success(results))
            print("fetched user results \(results)")
            print("successfully fetched data")
        }
    }
    
    
    public func getFilteredUserMatches(completion : @escaping (Result<[[String : Any]], Error>) -> Void) {
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
                    continue
                }
                let username = data["username"] as! String
                let goals = data["goals"] as! [String]
                results.append(["username": username, "email": user, "goals" : goals])
            }
            
            let currentUserGoals = currentUserData["goals"] as! [String]
            
            
            var filteredUsers = [[String : Any]]()
            
            for entry in results {
                let user = entry["email"] as! String
                let goals = entry["goals"] as! [String]
                let username = entry["username"]
                var matchTotal = 0
                for goal in goals {
                    for userGoal in currentUserGoals {
                        let tokens = userGoal.split(separator: " ")
                        for token in tokens {
                            if goal.contains(token) {
                                matchTotal += 1
                            }
                        }
                    }
                }
                if (matchTotal != 0) {
                    filteredUsers.append(["email" : user, "match" : matchTotal, "goals" : goals, "username" : username as! String])
                }
            }
            
            
            filteredUsers.sort {
                (($0 )["match"] as! Int) > (($1 )["match"] as! Int)
            }
            
            completion(.success(filteredUsers))
            print(filteredUsers)
            
        }
    }
    
    public enum DatabaseErrors : Error {
        case failedToFetch
    }
}


extension DatabaseManager {
    
    public func createNewConversation(otherUserNames: [String], otherUserEmails : [String], firstMessage : Message, completion : @escaping (Bool) -> Void) {
        guard let currentEmail = FirebaseAuth.Auth.auth().currentUser?.email else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let currentUsername = UserDefaults.standard.value(forKey: "username")
        print("current username when adding new conversation \(currentUsername)")
        
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
            "conv_name" : otherUserNames.joined(separator: ", "),
            "other_ids" : otherUserEmails,
            "other_names" : otherUserNames,
            "latest_message" : [
                "date" : dateString,
                "is_read" : false,
                "message" : message
            ],
            //            "name" : "name"
            ] as [String : Any]
        
        var recipientConversationData = [[String : Any]]()
        
        for i in 0...(otherUserEmails.count - 1) {
            let otherUserEmail = otherUserEmails[i]
            let otherUserName = otherUserNames[i]
            var otherEmails = otherUserEmails;
            otherEmails.removeAll(where: { $0 == otherUserEmail })
            otherEmails.append(safeEmail)
            var otherNames = otherUserNames
            otherNames.removeAll(where: { $0 == otherUserName })
            otherNames.append(currentUsername as! String)
            var data = [
                "id" : "conversation_\(firstMessage.messageId)",
                "conv_name" : otherNames.joined(separator: ", "),
                "other_ids" : otherEmails,
                "other_names" : otherNames,
                "latest_message" : [
                    "date" : dateString,
                    "is_read" : false,
                    "message" : message
                ],
                //            "name" : "name"
                ] as [String : Any]
            recipientConversationData.append(data)
        }
        
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
                    self?.finishCreatingConversation(otherUserNames: otherUserNames, conversationID: conversationId, firstMessage: firstMessage, completion: completion)                               }
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
                    self?.finishCreatingConversation(otherUserNames: otherUserNames, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
        }
        
        for i in 0...(otherUserEmails.count - 1) {
            let otherUserEmail = otherUserEmails[i]
            let data = recipientConversationData[i]
            database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] (snapshot) in
                if var conversations = snapshot.value as? [[String : Any]] {
                    //recipient has convos already
                    conversations.append(data)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }
                else {
                    self?.database.child("\(otherUserEmail)/conversations").setValue([data])
                }
            }
            
        }
        
        
    }
    
    private func finishCreatingConversation(otherUserNames: [String], conversationID: String, firstMessage: Message, completion : @escaping (Bool) -> Void) {
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
            "other_names" : otherUserNames,
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
                guard let conversationName = dictionary["conv_name"] as? String else {
                    print("unable to grab conversation name")
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
                guard let other_user_emails = dictionary["other_ids"] as? [String] else {
                    print("unable to make other_user_enai")
                    return nil
                }
                guard let other_names = dictionary["other_names"] as? [String] else {
                    print("not able to make into compact map")
                    return nil
                }
                
                print("conversationid \(conversationId)")
                
                let latestMessageObject = LatestMessage(date: date, text: message, is_read: is_read)
                
                
                return Conversation(id: conversationId, conv_name: conversationName, names: other_names, other_user_emails: other_user_emails, latest_message: latestMessageObject)
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
                    let names = dictionary["other_names"] as? [String],
                    let is_read = dictionary["is_read"] as? Bool,
                    let messageId = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let dateString = dictionary["date"] as? String else {
                        print("could not make messages into compact map")
                        return nil
                }
                
                let date = ChatViewController.dateFormatter.date(from: dateString)
                let displayName = names.joined(separator: ", ")
                let sender = Sender(senderId: senderEmail, displayName: displayName)
                
                return Message(sender: sender, messageId: messageId, sentDate: date!, kind: .text(content))
                
            })
            
            
            completion(.success(messages))
            
        }
    }
    
    public func sendMessage(otherUserEmails: [String], otherUserNames: [String], conversationId: String, message : Message, completion: @escaping (Bool) -> Void)
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
                "other_names" : otherUserNames,
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
                
                for otherUserEmail in otherUserEmails {
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
        
    }
    
    public func changeConvoName(name : String, id : String, completion : @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        
        database.child(safeEmail).child("conversations").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard var currentConversations = snapshot.value as? [[String : Any]] else {
                completion(false)
                return
            }
            
            var position = 0
            var targetConversation : [String : Any]?
            for conversation in currentConversations {
                if let currentId = conversation["id"] as? String, currentId == id {
                    targetConversation = conversation
                    break
                }
                position += 1
            }
            targetConversation?["conv_name"] = name
            guard let finalConversation = targetConversation else {
                completion(false)
                return
            }
            
            currentConversations[position] = finalConversation
            self?.database.child("\(safeEmail)/conversations").setValue(currentConversations) { (error, _) in
                guard error == nil else {
                    completion(false)
                    print("could not change name")
                    return
                }
                completion(true)
            }

        }
    
    }
    

    public func getUsername(email: String) -> String {
        var value = ""
        
        database.child(email).child("username").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                value = snapshot.value as! String
                UserDefaults.standard.set(value, forKey: "username")
            }
        }
        return value
        
    }
    
    
}

extension DatabaseManager {
    public func insertTip(tip : String) {
        database.child("tips").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if (snapshot.exists()) {
                //tips node already exists
                guard var tips = snapshot.value as? [String] else {
                    return
                }
                
                tips.append(tip)
                self?.database.child("tips").setValue(tips)
            }
                
            else {
                let tips = [tip]
                self?.database.child("tips").setValue(tips)
            }
        }
    }
    
    public func getTips(completion : @escaping (Result<[String], Error>) -> Void) {
        database.child("tips").observe(.value) { (snapshot) in
            guard snapshot.exists() else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            guard let tips = snapshot.value as? [String] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            completion(.success(tips))
        }
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


