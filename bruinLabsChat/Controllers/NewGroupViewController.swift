////
////  NewGroupViewController.swift
////  bruinLabsChat
////
////  Created by Reema Kshetramade on 8/1/20.
////  Copyright © 2020 Reema Kshetramade. All rights reserved.
////
//
//import UIKit
//import FirebaseAuth
//
//class NewGroupViewController: UIViewController {
//    
//    private let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.clipsToBounds = true
//        return scrollView
//    }()
//    
//    private let imageView: UIImageView = {
//         let imageView = UIImageView()
//         imageView.image = UIImage(systemName: "heart.circle")
//        let randomR = Float.random(in: 0.5..<1)
//        let randomG = Float.random(in: 0.5..<1)
//        let randomB = Float.random(in: 0.5..<1)
////         imageView.tintColor = .gray
//        imageView.tintColor = UIColor(displayP3Red: CGFloat(randomR), green: CGFloat(randomG), blue: CGFloat(randomB), alpha: 1)
//         imageView.contentMode = .scaleAspectFit
//         imageView.layer.masksToBounds = true
//         imageView.layer.borderWidth = 2
//         imageView.layer.borderColor = UIColor.white.cgColor
//         return imageView
//     }()
//    
//    private let nameTextField : UITextField = {
//        let name = UITextField()
//        name.autocapitalizationType = .none
//        name.autocorrectionType = .no
//        name.returnKeyType = .continue
//        name.layer.cornerRadius = 12
//        name.layer.borderWidth = 1
//        name.layer.borderColor = UIColor.lightGray.cgColor
//        name.placeholder = "group name..."
//        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
//        name.leftViewMode = .always
//        name.backgroundColor = .secondarySystemBackground
//        return name
//    }()
//    
//    private let tagsTextField : UITextField = {
//        let tags = UITextField()
//        tags.autocapitalizationType = .none
//        tags.autocorrectionType = .no
//        tags.returnKeyType = .continue
//        tags.layer.cornerRadius = 12
//        tags.layer.borderWidth = 1
//        tags.layer.borderColor = UIColor.lightGray.cgColor
//        tags.placeholder = "tag1, tag2, tag3"
//        tags.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
//        tags.leftViewMode = .always
//        tags.backgroundColor = .secondarySystemBackground
//        return tags
//    }()
//    
//    private let createButton : UIButton = {
//        let button = UIButton()
//        button.setTitle("create", for: .normal)
//        button.backgroundColor = UIColor(displayP3Red: 0.5058, green: 0.7569, blue: 0.7569, alpha: 1)
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 10.0
//        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 35)
//        button.contentVerticalAlignment = .center
//        return button
//    }()
//    
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(imageView)
//        scrollView.addSubview(nameTextField)
//        scrollView.addSubview(tagsTextField)
//        scrollView.addSubview(createButton)
//        
//        createButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//
//
//        view.backgroundColor = UIColor(displayP3Red: 0.843, green: 0.925, blue: 0.925, alpha: 1)
//        navigationController?.navigationBar.topItem?.title = "create a new group"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(dismissSelf))
//        
//        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
//        
//        imageView.isUserInteractionEnabled = true
//        scrollView.isUserInteractionEnabled = true
//        
//        let gesture = UITapGestureRecognizer(target: self,
//                                             action: #selector(didTapProfilePic))
//        imageView.addGestureRecognizer(gesture)
//    }
//    
//    @objc private func didTapProfilePic() {
//        presentPhotoActionSheet()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.frame = view.bounds
//
//        let size = scrollView.width/3
//        imageView.frame = CGRect(x: (scrollView.width-size)/2,
//                                 y: 20,
//                                 width: size*0.75,
//                                 height: size*0.75)
//
//        imageView.layer.cornerRadius = imageView.width/2.0
//
//        nameTextField.frame = CGRect(x: 30,
//                                  y: imageView.bottom+30,
//                                  width: scrollView.width-60,
//                                  height: 52)
//        tagsTextField.frame = CGRect(x: 30,
//                                  y: nameTextField.bottom+30,
//                                  width: scrollView.width-60,
//                                  height: 52)
//        createButton.frame = CGRect(x: 50,
//                                    y: tagsTextField.bottom+45,
//                                    width: scrollView.width-100,
//                                    height: 60)
//
//
//    }
//    
//    @objc private func didTapCreateButton() {
//        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//            tagsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
//        {
//            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
//            present(alert, animated: true)
//        }
//        
//        else {
//            
//            let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//            let tagsText = tagsTextField.text!.replacingOccurrences(of: ",", with: "")
//            let tags = tagsText.components(separatedBy: " ")
//            print("name: \(name); tags: \(tags)")
//            
//            DatabaseManager.shared.groupAlreadyExists(with: name, completion: { (exists) in
//                if exists {
//                // print("User already exists")
//                    let alert = UIAlertController(title: "oops!", message: "a group with that name already exists", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
//                    self.present(alert, animated: true)
//                    return
//                }
//            })
//                
//            DatabaseManager.shared.createGroup(with: NewGroup(name: name, tags: tags), completion: {success in
//                if success {
//                    //upload image
//                    guard let image = self.imageView.image, let data = image.pngData() else {
//                        return
//                    }
//                    
//                    let fileName = "\(name)_profile_picture.png"
//                    StorageManager.shared.uploadProfilePicture(with: data, filename: fileName) { (result) in
//                        switch result {
//                        case .success(let downloadUrl):
//                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
//                            print (downloadUrl)
//                        case .failure(let error):
//                            print("Storage manager error: \(error)")
//                        }
//                    }
//                }
//            })
//            
////            let user = DatabaseManager.safeEmail(email: (FirebaseAuth.Auth.auth().currentUser?.email)!)
////
////            DatabaseManager.shared.createNewGroupConvo(group: name, creator: user) { (success) in
////                if success {
////                    print("group successfully added to database")
////                }
////                else {
////                    print("group convo not added to database")
////                }
////            }
////
////            let alert = UIAlertController(title: "group created!", message: "please wait until other members join the group to start messaging", preferredStyle: .alert)
//////            alert.addAction(UIAlertAction(title: "got it", style: .cancel, handler: nil))
////            alert.addAction(UIAlertAction(title: "got it", style: .cancel, handler: { (action) in
////                self.navigationController?.dismiss(animated: true, completion: nil)
////            }))
////            self.present(alert, animated: true)
//            self.navigationController?.dismiss(animated: true, completion: nil)
////            var currEmail = FirebaseAuth.Auth.auth().currentUser!.email
////            currEmail = DatabaseManager.safeEmail(email: currEmail!)
////            let username = DatabaseManager.shared.getUsername(email: currEmail!)
////            let vc = ChatViewController(group_name: nameTextField.text!, emails: [currEmail! : username], id: "")
////            self.navigationController?.pushViewController(vc, animated: true)
//            
//        }
//    }
//    
//    @objc private func dismissSelf() {
//        dismiss(animated: true, completion: nil)
//    }
//    
//
//}
//
//extension NewGroupViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func presentPhotoActionSheet() {
//        let actionSheet = UIAlertController(title: "group picture", message: "choose a photo from:", preferredStyle: .actionSheet)
//        
//        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
//
//        actionSheet.addAction(UIAlertAction(title: "take a photo", style: .default, handler: { [weak self] (_) in
//            self?.presentCamera()
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "choose a photo", style: .default, handler: { [weak self] (_) in
//            self?.presentGallery()
//        }))
//        
//        present(actionSheet, animated: true)
//    }
//    
//    func presentCamera() {
//        let vc = UIImagePickerController()
//        vc.sourceType = .camera
//        vc.delegate = self
//        vc.allowsEditing = true
//        present(vc, animated: true)
//    }
//    
//    func presentGallery() {
//        let vc = UIImagePickerController()
//        vc.sourceType = .photoLibrary
//        vc.delegate = self
//        vc.allowsEditing = true
//        present(vc, animated: true)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//        
//
//    }
//    
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
//            return
//        }
//        self.imageView.image = selectedImage
//        
//        picker.dismiss(animated: true, completion: nil)
//    }
//}


//
//  ViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/26/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class NewGroupViewController: UIViewController {
    
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
        label.text = "no chats yet!"
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
        self.view.addSubview(tableView)
        self.view.addSubview(noConvsLabel)
        tableView.isHidden = false
//        self.title = "groups"
        setUpTableView()
//        fetchConversations()
        getMatches()
    }
    
    private func getMatches() {
        DatabaseManager.shared.getAllUsersGoals { [weak self] (result) in
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

extension NewGroupViewController : UITableViewDelegate, UITableViewDataSource {
    
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




