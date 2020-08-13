import UIKit
import FirebaseAuth
import JGProgressHUD


class TipsViewController: UIViewController {
    
    private var tips = [String]()
    
//    private var userMatches = [[String : Any]]()
    
    private var hasFetched = false
    
    private let tableView : UITableView = {
        let table = UITableView()
//        table.backgroundColor = .blue
        table.isHidden = true
//        table.tintColor
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(TipsTableViewCell.self, forCellReuseIdentifier: TipsTableViewCell.identifier)
        return table
    }()
    
    private let tipTextField : UITextField = {
        let text = UITextField()
        text.placeholder = "enter a tip"
        text.textAlignment = .center
        text.borderStyle = .roundedRect
        return text
    }()
    
    private let tipButton : UIButton = {
        let button = UIButton()
        button.setTitle("done", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(displayP3Red: 0.5058, green: 0.7569, blue: 0.7569, alpha: 1)
        button.layer.cornerRadius = 10.0
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 24)
        return button
    }()
    
    private let noConvsLabel : UILabel = {
        let label = UILabel()
        label.text = "no tips yet!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "tips"
        self.navigationItem.title = "tips"
        self.view.addSubview(tableView)
        self.view.addSubview(noConvsLabel)
        self.view.addSubview(tipTextField)
        self.view.addSubview(tipButton)
        tableView.isHidden = false
        tipButton.addTarget(self, action: #selector(didTapTipButton), for: .touchUpInside)
        setUpTableView()
        getTips()
    }
    
    @objc private func didTapTipButton() {        
        if (tipTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)) == "" {
            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        else {
            let tipText = tipTextField.text!
            tipTextField.text = ""
            DatabaseManager.shared.insertTip(tip: tipText)
        }
    }
    
    private func getTips() {
        print("getting tips")
        DatabaseManager.shared.getTips { [weak self] (result) in
            switch result {

            case .success(let tips):
                self?.tips = tips
                self?.tableView.isHidden = false
                self?.noConvsLabel.isHidden = true
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("error getting tips")
                self?.tableView.isHidden = true
                self?.noConvsLabel.isHidden = false
            }
        }
        print("got tips")
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: safeAreaFrame.height - 20)
        tipTextField.frame = CGRect(x: 10, y: tableView.bottom, width: view.width - 115, height: 50)
        tipButton.frame = CGRect(x: tipTextField.right + 5 , y: tableView.bottom, width: 90, height: 50)
    }
    
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchMatches() {
        tableView.isHidden = false
    }


}

extension TipsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("matches count \(tips.count)")
//        return tips.count
        return tips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TipsTableViewCell.identifier, for: indexPath) as! TipsTableViewCell
        cell.configure(text: tips[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}




