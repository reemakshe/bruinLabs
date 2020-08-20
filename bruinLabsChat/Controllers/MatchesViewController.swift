import UIKit
import FirebaseAuth
import JGProgressHUD


class MatchesViewController: UIViewController {
    
    private var matches = [ChatAppUser]()
    
    private var userMatches = [[String : Any]]()
    
    private var hasFetched = false
    
    private var selectedUsers = [ChatAppUser]()
    
    private let tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.allowsMultipleSelection = true
        table.register(UserMatchTableViewCell.self, forCellReuseIdentifier: UserMatchTableViewCell.identifier)
        return table
    }()
    
    private let noConvsLabel : UILabel = {
        let label = UILabel()
        label.text = "no matches yet!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "matches"
        self.view.addSubview(tableView)
        self.view.addSubview(noConvsLabel)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton))
        tableView.isHidden = false
        setUpTableView()
        getMatches()
    }
    
    @objc private func didTapDoneButton() {
        guard let selectedPaths = tableView.indexPathsForSelectedRows else {
            print("no selected rows")
            return
        }
        createNewConversation(users: selectedUsers)
    }
    
    private func getMatches() {
        DatabaseManager.shared.getFilteredUserMatches { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("error getting matches \(error)")
            case .success(let matches):
                self?.userMatches = matches
                print("user matches wo processing: \(matches)")
                self?.hasFetched = true
                for userMatch in (self?.userMatches)! {
                     let username = userMatch["username"] as! String
                     let email = userMatch["email"] as! String
                    let goals = userMatch["goals"] as! [String]
                     let user = ChatAppUser(username: username, email: email, goals: goals)
                     self?.matches.append(user)
                 }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            }
        }
        
 
        
        print("user matches!!! : \(userMatches)")
        
        tableView.reloadData()
        
        print("user matches that will be put in table view: \(matches)")
    }
        
    private func createNewConversation(users : [ChatAppUser]) {
        var names = [String]()
        var emails = [String]()
        for user in users {
            names.append(user.username)
            emails.append(user.email)
        }

        let name = names.joined(separator: ", ")
        print("names: \(names) and emails: \(emails)")
        
        let chatVC = ChatViewController(otherUser: emails, otherNames: names, id: nil)
        chatVC.title = name
        chatVC.isNewConversation = true

        navigationController?.popToRootViewController(animated: true)
        navigationController?.pushViewController(chatVC, animated: true)
        chatVC.navigationItem.largeTitleDisplayMode = .never
        print("putting new convo chat controller screen")
        
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        selectedUsers.removeAll()
    }
    
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchMatches() {
        tableView.isHidden = false
    }


}

extension MatchesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("matches count \(matches.count)")
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = matches[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
        cell.configure(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        if (cell.accessoryType == .checkmark) {
            cell.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: true)
            self.selectedUsers.remove(at: indexPath.row)
        }
        else {
            cell.accessoryType = .checkmark
            self.selectedUsers.append(matches[indexPath.row])
        }
//
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row < matches.count) {
            return 120
        }
        return 0
    }
}




