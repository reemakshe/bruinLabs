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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "sign up"
        label.font = UIFont(name: "Avenir-Heavy", size: 45)
        label.textColor = .white
        return label
    }()

    private let imageView: UIImageView = {
         let imageView = UIImageView()
         imageView.image = UIImage(systemName: "heart.circle")
        let randomR = Float.random(in: 0.5..<1)
        let randomG = Float.random(in: 0.5..<1)
        let randomB = Float.random(in: 0.5..<1)
        imageView.tintColor = UIColor(displayP3Red: CGFloat(randomR), green: CGFloat(randomG), blue: CGFloat(randomB), alpha: 1)
         imageView.contentMode = .scaleAspectFit
         imageView.layer.masksToBounds = true
         imageView.layer.borderWidth = 2
         imageView.layer.borderColor = UIColor.white.cgColor
         return imageView
     }()

    private let usernameTextField : UITextField = {
        let name = UITextField()
        name.autocapitalizationType = .none
        name.autocorrectionType = .no
        name.returnKeyType = .continue
        name.layer.cornerRadius = 12
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.lightGray.cgColor
        name.placeholder = "username"
        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        name.leftViewMode = .always
        name.backgroundColor = .secondarySystemBackground
        return name
    }()
    
    private let emailTextField : UITextField = {
        let email = UITextField()
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.returnKeyType = .continue
        email.layer.cornerRadius = 12
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.lightGray.cgColor
        email.placeholder = "email"
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        email.leftViewMode = .always
        email.backgroundColor = .secondarySystemBackground
        return email
    }()

    private let passwordTextField : UITextField = {
        let password = UITextField()
        password.autocapitalizationType = .none
        password.autocorrectionType = .no
        password.isSecureTextEntry = true
        password.returnKeyType = .continue
        password.layer.cornerRadius = 12
        password.layer.borderWidth = 1
        password.layer.borderColor = UIColor.lightGray.cgColor
        password.placeholder = "password"
        password.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        password.leftViewMode = .always
        password.backgroundColor = .secondarySystemBackground
        return password
    }()

    private let continueButton : UIButton = {
        let button = UIButton()
        button.setTitle("continue", for: .normal)
        button.backgroundColor = UIColor(displayP3Red: 0.5058, green: 0.7569, blue: 0.7569, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10.0
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 35)
        button.contentVerticalAlignment = .center
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        scrollView.addSubview(signUpLabel)
        scrollView.addSubview(imageView)
        scrollView.addSubview(usernameTextField)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(continueButton)

        continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true


        view.backgroundColor = UIColor(displayP3Red: 0.843, green: 0.925, blue: 0.925, alpha: 1)

        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true

        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapProfilePic))
        imageView.addGestureRecognizer(gesture)
    }

    @objc private func didTapProfilePic() {
        presentPhotoActionSheet()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds

        let size = scrollView.width/3
        signUpLabel.frame = CGRect(x: 25,
                                   y: 5,
                                   width: size*3,
                                   height: size*0.75)
        
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: signUpLabel.bottom + 5,
                                 width: size*0.85,
                                 height: size*0.85)

        imageView.layer.cornerRadius = imageView.width/2.0

        usernameTextField.frame = CGRect(x: 30,
                                  y: imageView.bottom+30,
                                  width: scrollView.width-60,
                                  height: 52)
        emailTextField.frame = CGRect(x: 30,
                                  y: usernameTextField.bottom+30,
                                  width: scrollView.width-60,
                                  height: 52)
        passwordTextField.frame = CGRect(x: 30,
                                         y: emailTextField.bottom+30,
                                         width: scrollView.width-60,
                                         height: 52)
        continueButton.frame = CGRect(x: 50,
                                    y: passwordTextField.bottom+45,
                                    width: scrollView.width-100,
                                    height: 60)


    }
    
    func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }

    @objc private func didTapContinueButton() {
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }

        else {

            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            
            DatabaseManager.shared.userExists(with: email) { (exists) in
                if exists {
                    //print("User already exists")
                    let alert = UIAlertController(title: "oops!", message: "a user with that email already exists", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
            }
            //
            
            if !self.isPasswordValid(password) {
                let alert = UIAlertController(title: "oops!", message: "please make sure your password is at least 8 characters, with 1 special character and 1 number", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                return
            }
            //
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                if error != nil {
                    print("error creating user \(error)")
                    let alert = UIAlertController(title: "oops!", message: "error creating user", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                    
                else {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(username: username, email: email, goals: []))
                    guard let image = self.imageView.image, let data = image.pngData() else {
                        return
                    }
                    
                    let safeEmail = DatabaseManager.safeEmail(email: email)
                    
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(username, forKey: "username")
                    
                    let fileName = "\(safeEmail)_profile_picture.png"
                    StorageManager.shared.uploadProfilePicture(with: data, filename: fileName) { (result) in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                            print (downloadUrl)
                        case .failure(let error):
                            print("Storage manager error: \(error)")
                        }
                    }
                    print("current user: \(FirebaseAuth.Auth.auth().currentUser?.email)")
                    //change root view controller to pick goals view controller instead of dismissing screen
                    let pickerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickerVC") as! PickGoalsViewController
                    self.navigationController?.pushViewController(pickerVC, animated: true)
                    self.navigationController?.navigationBar.isHidden = true
                }
            }
            
        }

    }


}

extension RegisterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "profile picture", message: "choose a photo from:", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))

        actionSheet.addAction(UIAlertAction(title: "camera", style: .default, handler: { [weak self] (_) in
            self?.presentCamera()
        }))

        actionSheet.addAction(UIAlertAction(title: "gallery", style: .default, handler: { [weak self] (_) in
            self?.presentGallery()
        }))

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func presentGallery() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)


    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage

        picker.dismiss(animated: true, completion: nil)
    }
}

