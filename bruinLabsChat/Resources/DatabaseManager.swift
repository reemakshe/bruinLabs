//
//  DatabaseManager.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/27/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    public func userExists(with email: String, completion : @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        print(safeEmail)
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
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
        database.child(user.safeEmail).setValue(["username" : user.username, "state" : user.state, "fun_fact" : user.funfact])
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
}
