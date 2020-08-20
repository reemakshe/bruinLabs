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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 75.0
        profileImageView.layer.borderColor = CGColor(srgbRed: 0.15686, green: 0.262745, blue: 0.3058823, alpha: 1)
        profileImageView.layer.borderWidth = 2.2
        let email = FirebaseAuth.Auth.auth().currentUser?.email as! String
        let safeEmail = DatabaseManager.safeEmail(email: email) as! String

        if safeEmail == nil {
            return
        }
        let path = "images/\(safeEmail)_profile_picture.png"

        
        emailTextLabel.text  = email
        usernameTextLabel.text = UserDefaults.standard.value(forKey: "username") as? String
        
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
            nav.navigationBar.isHidden = true
            present(nav, animated: true)

        }
        catch {
            print("failed to log out")
        }
    }
    
    
}


