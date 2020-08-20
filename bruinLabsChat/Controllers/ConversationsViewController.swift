//
//  ViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/26/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import JGProgressHUD


struct Conversation {
    let id : String
    let conv_name : String
    let names: [String]
    let other_user_emails : [String]
    let latest_message : LatestMessage
    
}

struct LatestMessage {
    let date : String
    let text : String
    let is_read : Bool
}

class ConversationsViewController: UIViewController {
        
    private var conversations = [Conversation]()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()
    
    private let noConvsLabel : UILabel = {
        let label = UILabel()
        label.text = "no chats yet!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapComposeButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapAddButton))
//        self.view.backgroundColor = .red
        self.navigationController?.isToolbarHidden = true
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        self.view.addSubview(noConvsLabel)
        tableView.isHidden = true
        noConvsLabel.isHidden = false
//        self.title = "groups"
        setUpTableView()
//        fetchConversations()
        startListeningForConversations()
    }
    
    private func startListeningForConversations() {
        print("listening for conversations")
        print(FirebaseAuth.Auth.auth().currentUser)
        
        print(UserDefaults.standard.value(forKey: "email") as? String)
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("no current user email")
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        print("user email: \(safeEmail)")
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self ](result) in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("conversations are empty")
                    self?.tableView.isHidden = true
                    self?.noConvsLabel.isHidden = false
                    return
                }
                self?.noConvsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get convos or no convos to get: \(error)")
                self?.tableView.isHidden = true
                self?.noConvsLabel.isHidden = false
            }
        }
    }
    
    @objc private func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = {[weak self] result in
            print("\(result)")
            guard let strongSelf = self else {
                return
            }
            let currentConversations = strongSelf.conversations
            
            if let targetConversation = currentConversations.first(where: {
                ($0.other_user_emails) == [(result["email"] as! String)] as [String]
            }) {
                

                let vc = ChatViewController(otherUser: targetConversation.other_user_emails, otherNames: targetConversation.names, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = (targetConversation.names).joined(separator: ", ")
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                
            }
            else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func createNewConversation(result: [String : Any]) {

        print("results: \(result)")
        guard let name = result["name"] as? String, let email = result["email"] as? String, let emails = [email] as? [String] else {
            print("NBAME EMIAL ERROR")
            return
        }
        let vc = ChatViewController(otherUser: emails, otherNames: [name], id: nil)
        vc.title = name
        vc.isNewConversation = true
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        print("putting new convo chat controller screen")
    }
    
    @objc private func didTapAddButton() {
        let vc = MatchesViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationItem
        validateAuth()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConvsLabel.frame = view.bounds
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        
        }
    }
    
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }



}

extension ConversationsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("convserations count \(conversations.count)")
        return conversations.count
    }
    
    func orderConversationsBasedOnTime() {
            conversations.sort {
            let val = ChatViewController.dateFormatter.date(from: ($0).latest_message.date)?.compare(ChatViewController.dateFormatter.date(from: ($1).latest_message.date)!)
            if val == ComparisonResult.orderedDescending {
                return true
            }
            else {
                return false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        orderConversationsBasedOnTime()
        
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        orderConversationsBasedOnTime()
        
        let model = conversations[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        openConversation(model: model)
        print("making chat view controller new controller")
        
    }
    
    func openConversation(model : Conversation) {
        let vc = ChatViewController(otherUser: model.other_user_emails, otherNames: model.names, id: model.id)
        vc.title = model.conv_name
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row < conversations.count) {
            return 120
        }
        return 0
    }
}



