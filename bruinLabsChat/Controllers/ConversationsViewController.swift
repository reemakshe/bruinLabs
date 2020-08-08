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
    let name: String
    let other_user_email : String
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
//        table.backgroundColor = .blue
        table.isHidden = true
//        table.tintColor
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
//        table.backgroundColor = UIColor(displayP3Red: 0.87058823, green: 0.956862, blue: 0.992156, alpha: 1)
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
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
//        let handle = Auth.auth().addStateDidChangeListener(<#T##listener: AuthStateDidChangeListenerBlock##AuthStateDidChangeListenerBlock##(Auth, User?) -> Void#>)
        print(FirebaseAuth.Auth.auth().currentUser)
//        if FirebaseAuth.Auth.auth().currentUser == nil {
//            print("current user is nil??")
//            return
//        }
        
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
                $0.other_user_email == DatabaseManager.safeEmail(email: result["email"]!)
            }) {
                
                let vc = ChatViewController(otherUser: targetConversation.other_user_email, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
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
    
    private func createNewConversation(result: [String : String]) {
//        let groupName = Array(result.keys)[0]
//        let members = result[groupName]
//        let names = result["names"]
        print("results: \(result)")
        guard let name = result["name"], let email = result["email"] else {
            print("NBAME EMIAL ERROR")
            return
        }
        let vc = ChatViewController(otherUser: email, id: nil)
        vc.title = name
//        let vc = ChatViewController(gr: groupName, with: members!)
        vc.isNewConversation = true
//        let nav = UINavigationController(rootViewController: ConversationsViewController())
//        vc.title = "Group One"
//        vc.navigationItem.largeTitleDisplayMode = .never
//        nav.pushViewController(vc, animated: true)
//        self.view.window?.makeKeyAndVisible()
//        vc.title = groupName
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        print("putting new convo chat controller screen")
    }
    
    @objc private func didTapAddButton() {
        let vc = NewGroupViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        present(nav, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        validateAuth()

//        startListeningForConversations()
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
//        return 1
    }
    
    func orderConversationsBasedOnTime() {
        var ordered = [Conversation]()
        
        for conversation in conversations {
            //implement some sorting algorithm based on date if there is time
            //let currConvDate
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
//        cell.textLabel?.text = "Hello world"
//        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = conversations[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        openConversation(model: model)
        print("making chat view controller new controller")
        
    }
    
    func openConversation(model : Conversation) {
        let vc = ChatViewController(otherUser: model.other_user_email, id: model.id)
        vc.title = model.name
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



