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
    
    public var completion: (([String : String] )-> Void)?
    
//    private var groups = [String : [String : [String : String]]]()
//    private var results = [Dictionary<String, Int>.Element]()
    private var users = [[String : String]]()
    private var results = [[String : String]]()
    private var usersWithGoals = [[String : Any]]()
    private var resultsWithGoals = [[String : Any]]()

//    private var groups = [String : Any]()
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
        print("results \(results)")
        print("results count \(self.results.count)")
//        return self.results.count
        //choosing at most the 5 most relevant groups to display
//        return min(self.results.count, 5)
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("putting thing in table view")
//        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath)
//        cell.textLabel!.text = results[indexPath.row]["name"]
        let result = results[indexPath.row]
        let user = ChatAppUser(username: result["name"] as! String, email: result["email"] as! String, goals: [""])
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
        cell.configure(user: user)
//        print(results[indexPath.row]["name"])
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
        //start conversation
//        let name = results[indexPath.row]["name"]
////        let groupMembers = Array((groups[groupName])!["members"]?.keys)
////        let groupMembersNames = (groups[groupName])!["members"] as! [String : String]
////        let groupNames = Array((groups[groupName])!["names"]!.keys)
//        let targetGroup = [groupName : groupMembersNames]
////        let targetGroup = groups[results[indexPath.row].key]
//        completion?(targetGroup)
//        dismiss(animated: true) { [weak self] in
//            self?.completion?(targetGroup)
//        }
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
        //check if there is a group with that name or groups with tags in query
        //try -> for each word in query, if a group name/tags has no common things do not show it, then rank
        //further based on how many words in query are in that
        //maybe gives 2x points if the words are in the name of the group?
        
        if hasFetched {
            filterUsers(query: query)
        }
        
        else {
            DatabaseManager.shared.getAllUsers { [weak self] (result) in
                switch result {
                case .success(let groupsCollection):
//                    print("calling filter")
                    self?.users = groupsCollection
                    self?.hasFetched = true
                    self?.filterUsers(query: query)
                case .failure(let error):
                    print("Failed to get groups \(error)")
                }
            }
            DatabaseManager.shared.getAllUsersGoals { [weak self] (result) in
                            switch result {
                            case .success(let groupsCollection):
            //                    print("calling filter")
                                self?.usersWithGoals = groupsCollection
                                self?.hasFetched = true
                                self?.filterUsers(query: query)
                            case .failure(let error):
                                print("Failed to get groups \(error)")
                            }
            }
        }
        
        
    }
    
    func filterUsers(query : String) {
        guard hasFetched, let email = FirebaseAuth.Auth.auth().currentUser?.email, let safeEmail = DatabaseManager.safeEmail(email: email) as? String else {
            return
        }
        print("not filtered results: \(users)")
        
        var results: [[String : String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased(), $0["email"] != safeEmail else {
                return false
            }
            
//            let email = $0["email"]
            
            return name.hasPrefix(query.lowercased())
        })
        
//        var resultsWithGoals: [[String : Any]] = self.usersWithGoals.filter({
//            guard var name = $0["name"] as? String, name = name.lowercased(),
//        })
        
        print("filtered results: \(results)")
        self.results = results
        updateUI()
        
    }
    
//    func filterGroups(with term : String) {
//        guard hasFetched else {
//            return
//        }
//        
////        var results : [String : Any] = self.groups.filter { (term, Any) -> Bool in
////
////        }
//        var groupMatches = [String : Int]()
//        for (group, results) in groups {
////            print("filtering")
//            groupMatches[group] = Tools.levenshtein(aStr: group, bStr: term)
//
//            let tags = results["tags"]
//            for (tag, _) in tags! {
//                var val : Int
//                if groupMatches[group] == nil {
//                    val = 0
//                }
//                else {
//                    val = groupMatches[group]!
//                }
//                val += Tools.levenshtein(aStr: tag, bStr: term)
//                groupMatches[group] = val
//            }
////            print("tags: \(tags)")
//            
//        }
//        
//        var sortedGroupMatches = groupMatches.sorted(by: { $0.value >= $1.value })
////        print(sortedGroupMatches)
//        self.results = sortedGroupMatches
////        print("key \(results[0].key)")
//        
//        updateUI()
//        
//    }
    
    func updateUI() {
        if results.isEmpty {
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
