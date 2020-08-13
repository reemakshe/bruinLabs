import UIKit
import FirebaseAuth
import JGProgressHUD


class MatchesViewController: UIViewController {
    
    private var matches = [ChatAppUser]()
    
    private var userMatches = [[String : Any]]()
    
    private var hasFetched = false
    
    private let tableView : UITableView = {
        let table = UITableView()
//        table.backgroundColor = .blue
        table.isHidden = true
//        table.tintColor
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
    
    //implement to allow user to choose what matches are based on
    private let pickerView : UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
//        self.view.backgroundColor = .red
        self.title = "matches"
        self.view.addSubview(tableView)
        self.view.addSubview(noConvsLabel)
//        tableView.backgroundColor = UIColor(displayP3Red: 0.85882, green: 0.92941, blue: 0.964705, alpha: 1)
        tableView.isHidden = false
//        self.title = "groups"
        setUpTableView()
//        fetchConversations()
        getMatches()
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
        
//    @objc private func didTapComposeButton() {
//        let vc = NewConversationViewController()
//        vc.completion = {[weak self] result in
//            print("\(result)")
//            self?.createNewConversation(result: result)
//        }
//        let nav = UINavigationController(rootViewController: vc)
//        present(nav, animated: true)
//    }
    
    private func createNewConversation(user : ChatAppUser) {

        let name = user.username
        let email = user.safeEmail
        let vc = ChatViewController(otherUser: email, id: nil)
        vc.title = name
        vc.isNewConversation = true

        navigationController?.popToRootViewController(animated: true)
        navigationController?.pushViewController(vc, animated: true)
        vc.navigationItem.largeTitleDisplayMode = .never
        print("putting new convo chat controller screen")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
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
//        return 1
    }
    
//    func orderConversationsBasedOnTime() {
//        var ordered = [Conversation]()
//
//        for match in userMatches {
//            //implement some sorting algorithm based on date if there is time
//            //let currConvDate
//        }
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let userDict = userMatches[indexPath.row]
//        let user = ChatAppUser(username: userDict["username"] as! String, email: userDict["email"] as! String, goals: userDict["goals"] as! [String])
        let user = matches[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMatchTableViewCell.identifier, for: indexPath) as! UserMatchTableViewCell
        cell.configure(user: user)
//        cell.textLabel?.text = "Hello world"
//        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = matches[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        createNewConversation(user: user)
        print("making chat view controller new controller")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row < matches.count) {
            return 120
        }
        return 0
    }
}




