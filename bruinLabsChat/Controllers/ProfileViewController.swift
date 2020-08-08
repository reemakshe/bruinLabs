//
//  ProfileViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/26/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage


class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var usernameTextLabel: UILabel!
    
    
    @IBOutlet weak var emailTextLabel: UILabel!
    
    
    //    @IBOutlet var tableView : UITableView!
    
    //    let data = ["log out"]
    
//    let email = FirebaseAuth.Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //        tableView.delegate = self
        //        tableView.dataSource = self
        profileImageView.layer.cornerRadius = 75.0
//        let email = UserDefaults.standard.value(forKey: "email") as! String
        let email = FirebaseAuth.Auth.auth().currentUser?.email as! String
        let safeEmail = DatabaseManager.safeEmail(email: email) as! String

        if safeEmail == nil {
            return
        }
        print("safe email: \(safeEmail)")
        let path = "images/\(safeEmail)_profile_picture.png"
        print("image path: \(path)")
        
//        DispatchQueue.main.async {
//            let username = DatabaseManager.shared.getUsername(email: safeEmail)
//            self.usernameTextLabel.text = username
//            print("username: \(username)")
//
//        }
        
//        let username = UserDefaults.standard.value(forKey: "username") as? String
//        print("username from user defaults: \(username)")
        print("email: \(email)")
        
        usernameTextLabel.text = email.replacingOccurrences(of: "@test.com", with: "")
        emailTextLabel.text  = email
        
        StorageManager.shared.downloadURL(for: path) { [weak self] (result) in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.profileImageView.sd_setImage(with: url, completed: nil)

                }
            case .failure(let error):
                print("failed to get image: \(error)")
            }
        }
        
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            
            let currentUser = FirebaseAuth.Auth.auth().currentUser?.email
            print("current user: \(currentUser)")
            UserDefaults.standard.set(nil, forKey: "email")
            UserDefaults.standard.set(nil, forKey: "username")
            print("\(UserDefaults.standard.value(forKey: "email"))")
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
        catch {
            print("failed to log out")
        }
    }
    
    
}




//extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return data.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = data[indexPath.row]
//        cell.textLabel?.textAlignment = .center
//        cell.textLabel?.textColor = .red
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        do {
//            try FirebaseAuth.Auth.auth().signOut()
//
//            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
//            let nav = UINavigationController(rootViewController: loginVC)
//            nav.modalPresentationStyle = .fullScreen
//            present(nav, animated: true)
//        }
//        catch {
//            print("failed to log out")
//        }
//    }
//}
