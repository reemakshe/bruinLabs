//
//  PickGoalsViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 8/6/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth

class PickGoalsViewController: UIViewController {
    

    
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    @IBOutlet weak var firstSpecificTextField: UITextField!
    
    
    @IBOutlet weak var secondSpecificTextField: UITextField!
    
    
    @IBOutlet weak var thirdSpecificTextField: UITextField!
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        doneButton.layer.cornerRadius = 10.0
    
    }
    
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        //put in database and go to chats page
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            print("no user")
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        let firstSpecific = firstSpecificTextField.text
        let secondSpecific = secondSpecificTextField.text
        let thirdSpecific = thirdSpecificTextField.text
        
        
        if firstSpecific?.trimmingCharacters(in: .whitespaces) == "" ||
            secondSpecific?.trimmingCharacters(in: .whitespaces) == "" ||
            thirdSpecific?.trimmingCharacters(in: .whitespaces) == "" {
            let alert = UIAlertController(title: "oops!", message: "please enter all your goals", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        goals = [firstSpecific as! String, secondSpecific as! String, thirdSpecific as! String]


        DatabaseManager.shared.insertGoals(email: safeEmail, goals: goals)
//
        let convVC = self.storyboard?.instantiateViewController(withIdentifier: "tabVC") as! UITabBarController
        convVC.modalPresentationStyle = .fullScreen
        self.present(convVC, animated: true)
    }
    
    
}
