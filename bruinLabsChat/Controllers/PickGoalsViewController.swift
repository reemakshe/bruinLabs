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
    
    @IBOutlet weak var firstGoalButton: UIButton!
    

    @IBOutlet weak var secondGoalButton: UIButton!
    
    
    @IBOutlet weak var thirdGoalButton: UIButton!
    
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    @IBOutlet weak var firstGoalPicker: UIPickerView!
    
    
    @IBOutlet weak var secondGoalPicker: UIPickerView!
    
    
    @IBOutlet weak var thirdGoalPicker: UIPickerView!
    
    var pickerData = [String]()
    
    var goals = ["", "", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstGoalButton.layer.cornerRadius = 10.0
        secondGoalButton.layer.cornerRadius = 10.0
        thirdGoalButton.layer.cornerRadius = 10.0
        doneButton.layer.cornerRadius = 10.0
        
        firstGoalButton.titleLabel?.adjustsFontSizeToFitWidth = true
        secondGoalButton.titleLabel?.adjustsFontSizeToFitWidth = true
        thirdGoalButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        pickerData = ["fitness", "education", "mental health", "for fun"]
        
        firstGoalPicker.delegate = self
        firstGoalPicker.dataSource = self
        
        secondGoalPicker.delegate = self
        secondGoalPicker.dataSource = self
        
        thirdGoalPicker.delegate = self
        thirdGoalPicker.dataSource = self
        

    }
    
    @IBAction func firstButtonClicked(_ sender: Any) {
        firstGoalPicker.backgroundColor = view.backgroundColor
        firstGoalPicker.isHidden = false
        view.bringSubviewToFront(firstGoalPicker)
//        view.alpha = 0.5
//        firstGoalPicker.alpha = 1
    }
    
    @IBAction func secondButtonClicked(_ sender: Any) {
        secondGoalPicker.backgroundColor = view.backgroundColor
        secondGoalPicker.isHidden = false
        view.bringSubviewToFront(secondGoalPicker)
//        view.alpha = 0.5
//        secondGoalPicker.alpha = 1
    }
    
    @IBAction func thirdButtonClicked(_ sender: Any) {
        thirdGoalPicker.backgroundColor = view.backgroundColor
        thirdGoalPicker.isHidden = false
        view.bringSubviewToFront(thirdGoalPicker)
//        view.alpha = 0.5
//        thirdGoalPicker.alpha = 1
    }
    
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        //put in database and go to chats page
        guard let email = FirebaseAuth.Auth.auth().currentUser?.email else {
            print("no user")
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        DatabaseManager.shared.insertGoals(email: safeEmail, goals: goals)
//        self.navigationController?.pushViewController(ConversationsViewController(), animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension PickGoalsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //change text in text view to selected goal
        if pickerView == firstGoalPicker {
            firstGoalButton.titleLabel?.text = pickerData[row]
            goals[0] = pickerData[row]
            firstGoalPicker.isHidden = true
            view.alpha = 1
        }
        else if pickerView == secondGoalPicker {
            secondGoalButton.titleLabel?.text = pickerData[row]
            goals[1] = pickerData[row]
            secondGoalPicker.isHidden = true
            view.alpha = 1
        }
        else {
            thirdGoalButton.titleLabel?.text = pickerData[row]
            goals[2] = pickerData[row]
            thirdGoalPicker.isHidden = true
            view.alpha = 1
        }
                
        
    }
    
    
}
