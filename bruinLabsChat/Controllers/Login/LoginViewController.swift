//
//  LoginViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/26/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        loginButton.layer.cornerRadius = 10.0
        signUpButton.layer.cornerRadius = 10.0
        errorLabel.alpha = 0
        
    }
    
    
    @IBAction func didTapLogin(_ sender: Any) {
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        
        else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    let alert = UIAlertController(title: "oops!", message: "email or password entered in incorrect", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                
                else {
//                    let user = result!.user
                    UserDefaults.standard.set(email, forKey: "email")
                    let safeEmail = DatabaseManager.safeEmail(email: email)
                    let group = DispatchGroup()
                    group.enter()
                    let username = ""
                    DatabaseManager.shared.getUsername(email: safeEmail)

                    print("user defaults: \(email), \(username)")
                    let convVC = self.storyboard?.instantiateViewController(withIdentifier: "tabVC") as! UITabBarController
                    convVC.modalPresentationStyle = .fullScreen
                    self.present(convVC, animated: true)
                    
                }
            }
            
        }

    }
    

    @IBAction func didTapSignUp(_ sender: Any) {
        let regVC = RegisterViewController()
        navigationController?.pushViewController(regVC, animated: true)
    }
    
    
}
