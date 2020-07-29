//
//  RegisterViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 7/26/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth


class RegisterViewController: UIViewController {
    

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var stateTextField: UITextField!
    
    
    @IBOutlet weak var funFactTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        continueButton.layer.cornerRadius = 10.0
    }
    
    func isPasswordValid(_ password : String) -> Bool {
           
           let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
           return passwordTest.evaluate(with: password)
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           stateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
           funFactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
        //            errorLabel.text = "Please enter all fields."
        //            errorLabel.alpha = 1
                    
            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }

//        else if !isPasswordValid(passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
//        {
//            let alert = UIAlertController(title: "oops!", message: "please make sure your password is at least 8 characters, with 1 special character and 1 number", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
//            present(alert, animated: true)
//        }
        
        else {
            
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let state = stateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let funfact = funFactTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            DatabaseManager.shared.userExists(with: email) { (exists) in
                if exists {
//                    print("User already exists")
                    let alert = UIAlertController(title: "oops!", message: "a user with that email already exists", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
//                print("user does not already exist")
            }
                
                
            if !self.isPasswordValid(password) {
                let alert = UIAlertController(title: "oops!", message: "please make sure your password is at least 8 characters, with 1 special character and 1 number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    let alert = UIAlertController(title: "oops!", message: "error creating user", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                
                else {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(username: username, email: email, state: state, funfact: funfact))
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        
        }
        
    }
    

}
