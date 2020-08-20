//
//  NewConversationViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/26/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewConversationViewController: UIViewController {
    
    public var completion: (([String : Any] )-> Void)?

    private var users = [[String : Any]]()
    private var results = [[String : Any]]()
    private var usersWithGoals = [[String : Any]]()
    private var resultsWithGoals = [[String : Any]]()

    private var hasFetched = false
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "find a new friend..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.rowHeight = 120
        table.register(UserMatchTableViewCell.self, forCellReuseIdentifier: UserMatchTableViewCell.identifier)
        return table
    }()
    
    private let noResultsLabel : UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "no matches :("
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }


}

extension NewConversationViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = results[indexPath.row]
        let user = ChatAppUser(username: result["name"] as! String, email: result["email"] as! String, goals: result["goals"] as! [String])
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
        cell.configure(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 120
       }

    }
}

extension NewConversationViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        
        if hasFetched {
            filterUsers(query: query.lowercased())
        }
        
        else {
            DatabaseManager.shared.getAllUsers { [weak self] (result) in
                switch result {
                case .success(let usersCollection):
                    self?.users = usersCollection
                    self?.hasFetched = true
                    self?.filterUsers(query: query.lowercased())
                case .failure(let error):
                    print("Failed to get users \(error)")
                }
            }

        }
        
        
    }
    
    func filterUsers(query : String) {
        guard hasFetched, let email = FirebaseAuth.Auth.auth().currentUser?.email, let safeEmail = DatabaseManager.safeEmail(email: email) as? String else {
            return
        }
        print("not filtered results: \(users)")
        
        let results: [[String : Any]] = self.users.filter({
            guard let rawname = $0["name"] as? String, let goals = $0["goals"] as? [String] else {
                print("could not format vars")
                return false
            }
            let name = rawname.lowercased()
            let allGoals = (goals.joined(separator: " ")).lowercased()
            print("allgoals: \(allGoals)")
            print("query: \(query)")
            return allGoals.contains(query) || name.hasPrefix(query.lowercased())
        })
        
        print("filtered results: \(results)")
        self.results = results
        updateUI()
        
    }
    
    func updateUI() {
        if results.count == 0 {
            print("results are empty")
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        }
        else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
