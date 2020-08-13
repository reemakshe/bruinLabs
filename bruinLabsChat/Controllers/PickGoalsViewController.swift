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
    
    
    
    var pickerData = [String]()
    
    //    var goals = ["", "", ""]
    
    //    var specificGoals = ["", "", ""]
    
    var goals  = [String]()
    
    var firstKey = String();
    var secondKey = String();
    var thirdKey = String();
    
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
        //        self.navigationController?.pushViewController(ConversationsViewController(), animated: true)
        //        self.dismiss(animated: true, completion: nil)
        let convVC = self.storyboard?.instantiateViewController(withIdentifier: "tabVC") as! UITabBarController
        let nav = UINavigationController(rootViewController: convVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    
}

//extension PickGoalsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return pickerData.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return pickerData[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        //change text in text view to selected goal
//        if pickerView == firstGoalPicker {
//            firstGoalButton.titleLabel?.text = pickerData[row]
//            firstGoalPicker.isHidden = true
//            view.alpha = 1
//            //            let alert = UIAlertController(title: "info!", message: "enter a specific goal", preferredStyle: .alert)
//            //            alert.addTextField { (textField) in
//            //                textField.placeholder = "ex: better study habits"
//            //            }
//            //            alert.addAction(UIAlertAction(title: "done", style: .default, handler: { [weak self] (_) in
//            //                self?.specificGoals[0] = (alert.textFields![0]).text as! String
//            //                print("from alert \(alert.textFields![0].text as! String)")
//            //            }))
//            //            self.present(alert, animated: true)
//            //            print("specific goal: \(specificGoals[0])")
//        }
//        else if pickerView == secondGoalPicker {
//            secondGoalButton.titleLabel?.text = pickerData[row]
//            secondGoalPicker.isHidden = true
//            view.alpha = 1
//        }
//        else {
//            thirdGoalButton.titleLabel?.text = pickerData[row]
//            thirdGoalPicker.isHidden = true
//            view.alpha = 1
//        }
//
//        goals[pickerData[row]] = ""
//
//
//
//    }
//
//
//}
