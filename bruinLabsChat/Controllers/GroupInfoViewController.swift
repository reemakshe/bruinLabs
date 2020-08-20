//
//  GroupInfoViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 8/14/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth

class GroupInfoViewController: UIViewController {
    
    private var otherEmails : [String]
    private var otherNames : [String]
    public var groupName = String()
    private var convId : String
    private var chatVC : ChatViewController
    
    init(otherEmails: [String], otherNames : [String], conv_id : String, chat : ChatViewController) {
        self.otherEmails = otherEmails
        self.otherNames = otherNames
        self.convId = conv_id
        self.chatVC = chat
        self.groupName = chat.title!
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    

    private let nameTextField : UITextField = {
        let name = UITextField()
        name.autocapitalizationType = .none
        name.autocorrectionType = .no
        name.returnKeyType = .continue
        name.layer.cornerRadius = 12
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.lightGray.cgColor
        name.placeholder = "group name..."
        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        name.leftViewMode = .always
        name.backgroundColor = .secondarySystemBackground
        return name
    }()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        table.register(UserMatchTableViewCell.self, forCellReuseIdentifier: UserMatchTableViewCell.identifier)
        return table
    }()
    
    private let createButton : UIButton = {
        let button = UIButton()
        button.setTitle("done", for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 0.5058, green: 0.7569, blue: 0.7569, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10.0
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 25)
        button.contentVerticalAlignment = .center
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.placeholder = chatVC.title!
        view.addSubview(scrollView)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(createButton)
        scrollView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        createButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true


        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.title = "edit chat info"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        
        scrollView.isUserInteractionEnabled = true

    }
    
//
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3

        nameTextField.frame = CGRect(x: 30,
                                  y: 20,
                                  width: scrollView.width-150,
                                  height: 52)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.frame = CGRect(x: 0, y: nameTextField.bottom + 10, width: view.width, height: safeAreaFrame.height - 60)
        tableView.backgroundColor = view.backgroundColor
        createButton.frame = CGRect(x: nameTextField.right + 10,
                                    y: nameTextField.top + 5,
                                    width: 75,
                                    height: 40)


    }
    
    @objc private func didTapCreateButton() {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        
        else {
            
            let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.groupName = name
            DatabaseManager.shared.changeConvoName(name: name, id: convId) { [weak self] (result) in
                if result {
                    print("changed name")
                    self?.chatVC.changeChatTitle(name: name)
                }
            }

            self.navigationController?.dismiss(animated: true, completion: nil)
            
            
        }
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    

}

extension GroupInfoViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return otherNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let username = otherNames[indexPath.row]
        let email = otherEmails[indexPath.row]
        let goals = [""]
        let user = ChatAppUser(username: username, email: email, goals: goals)
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
        cell.configure(user: user)
        cell.backgroundColor = view.backgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
