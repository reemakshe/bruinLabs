////
////  RegisterViewController.swift
////  bruinLabsChat
////
////  Created by Reema Kshetramade on 7/26/20.
////  Copyright © 2020 Reema Kshetramade. All rights reserved.
////
//
//import UIKit
//import FirebaseAuth
//
//
//class RegisterViewController: UIViewController {
//
//
//    @IBOutlet weak var usernameTextField: UITextField!
//
//    @IBOutlet weak var emailTextField: UITextField!
//
//    @IBOutlet weak var passwordTextField: UITextField!
//
//
//    @IBOutlet weak var continueButton: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        continueButton.layer.cornerRadius = 10.0
//    }
//
//    func isPasswordValid(_ password : String) -> Bool {
//
//           let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
//           return passwordTest.evaluate(with: password)
//    }
//
//    @IBAction func didTapContinueButton(_ sender: Any) {
//
//        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//           passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//           usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//           stateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
//           funFactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
//        {
//        //            errorLabel.text = "Please enter all fields."
//        //            errorLabel.alpha = 1
//
//            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
//            present(alert, animated: true)
//        }
//
//
//        else {
//
//            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//            let username = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//
//            DatabaseManager.shared.userExists(with: email) { (exists) in
//                if exists {
////                    print("User already exists")
//                    let alert = UIAlertController(title: "oops!", message: "a user with that email already exists", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
//                    self.present(alert, animated: true)
//                    return
//                }
////                print("user does not already exist")
//            }
//
//
//            if !self.isPasswordValid(password) {
//                let alert = UIAlertController(title: "oops!", message: "please make sure your password is at least 8 characters, with 1 special character and 1 number", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
//                self.present(alert, animated: true)
//                return
//            }
//
//            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
//                if error != nil {
//                    let alert = UIAlertController(title: "oops!", message: "error creating user", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
//                    self.present(alert, animated: true)
//                    return
//                }
//
//                else {
//                    DatabaseManager.shared.insertUser(with: ChatAppUser(username: username, email: email))
//                    self.navigationController?.dismiss(animated: true, completion: nil)
//                }
//            }
//
//        }
//
//    }
//
//
//}



//
//  NewGroupViewController.swift
//  bruinLabsChat
//
//  Created by Reema Kshetramade on 8/1/20.
//  Copyright © 2020 Reema Kshetramade. All rights reserved.
//

import UIKit
import FirebaseAuth

class NewGroupViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "sign up"
    }

    private let imageView: UIImageView = {
         let imageView = UIImageView()
         imageView.image = UIImage(systemName: "heart.circle")
        let randomR = Float.random(in: 0.5..<1)
        let randomG = Float.random(in: 0.5..<1)
        let randomB = Float.random(in: 0.5..<1)
//         imageView.tintColor = .gray
        imageView.tintColor = UIColor(displayP3Red: CGFloat(randomR), green: CGFloat(randomG), blue: CGFloat(randomB), alpha: 1)
         imageView.contentMode = .scaleAspectFit
         imageView.layer.masksToBounds = true
         imageView.layer.borderWidth = 2
         imageView.layer.borderColor = UIColor.white.cgColor
         return imageView
     }()

    private let nameTextField : UITextField = {
        let name = UITextField()
        name.autocapitalizationType = .none
        name.autocorrectionType = .no
        name.returnKeyType = .continue
        name.layer.cornerRadius = 12
        name.layer.borderWidth = 1
        name.layer.borderColor = UIColor.lightGray.cgColor
        name.placeholder = "group name..."
        name.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        name.leftViewMode = .always
        name.backgroundColor = .secondarySystemBackground
        return name
    }()

    private let tagsTextField : UITextField = {
        let tags = UITextField()
        tags.autocapitalizationType = .none
        tags.autocorrectionType = .no
        tags.returnKeyType = .continue
        tags.layer.cornerRadius = 12
        tags.layer.borderWidth = 1
        tags.layer.borderColor = UIColor.lightGray.cgColor
        tags.placeholder = "tag1, tag2, tag3"
        tags.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        tags.leftViewMode = .always
        tags.backgroundColor = .secondarySystemBackground
        return tags
    }()

    private let createButton : UIButton = {
        let button = UIButton()
        button.setTitle("create", for: .normal)
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
        scrollView.addSubview(imageView)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(tagsTextField)
        scrollView.addSubview(createButton)

        createButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true


        view.backgroundColor = UIColor(displayP3Red: 0.843, green: 0.925, blue: 0.925, alpha: 1)
        navigationController?.navigationBar.topItem?.title = "create a new group"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(dismissSelf))

        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)

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
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size*0.75,
                                 height: size*0.75)

        imageView.layer.cornerRadius = imageView.width/2.0

        nameTextField.frame = CGRect(x: 30,
                                  y: imageView.bottom+30,
                                  width: scrollView.width-60,
                                  height: 52)
        tagsTextField.frame = CGRect(x: 30,
                                  y: nameTextField.bottom+30,
                                  width: scrollView.width-60,
                                  height: 52)
        createButton.frame = CGRect(x: 50,
                                    y: tagsTextField.bottom+45,
                                    width: scrollView.width-100,
                                    height: 60)


    }

    @objc private func didTapCreateButton() {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            tagsTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            let alert = UIAlertController(title: "oops!", message: "please enter all fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }

        else {

            let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let tagsText = tagsTextField.text!.replacingOccurrences(of: ",", with: "")
            let tags = tagsText.components(separatedBy: " ")
            print("name: \(name); tags: \(tags)")

            DatabaseManager.shared.groupAlreadyExists(with: name, completion: { (exists) in
                if exists {
                // print("User already exists")
                    let alert = UIAlertController(title: "oops!", message: "a group with that name already exists", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "try again", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
            })

            DatabaseManager.shared.createGroup(with: NewGroup(name: name, tags: tags), completion: {success in
                if success {
                    //upload image
                    guard let image = self.imageView.image, let data = image.pngData() else {
                        return
                    }

                    let fileName = "\(name)_profile_picture.png"
                    StorageManager.shared.uploadProfilePicture(with: data, filename: fileName) { (result) in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                            print (downloadUrl)
                        case .failure(let error):
                            print("Storage manager error: \(error)")
                        }
                    }
                }
            })

//            let user = DatabaseManager.safeEmail(email: (FirebaseAuth.Auth.auth().currentUser?.email)!)
//
//            DatabaseManager.shared.createNewGroupConvo(group: name, creator: user) { (success) in
//                if success {
//                    print("group successfully added to database")
//                }
//                else {
//                    print("group convo not added to database")
//                }
//            }
//
//            let alert = UIAlertController(title: "group created!", message: "please wait until other members join the group to start messaging", preferredStyle: .alert)
////            alert.addAction(UIAlertAction(title: "got it", style: .cancel, handler: nil))
//            alert.addAction(UIAlertAction(title: "got it", style: .cancel, handler: { (action) in
//                self.navigationController?.dismiss(animated: true, completion: nil)
//            }))
//            self.present(alert, animated: true)
            self.navigationController?.dismiss(animated: true, completion: nil)
//            var currEmail = FirebaseAuth.Auth.auth().currentUser!.email
//            currEmail = DatabaseManager.safeEmail(email: currEmail!)
//            let username = DatabaseManager.shared.getUsername(email: currEmail!)
//            let vc = ChatViewController(group_name: nameTextField.text!, emails: [currEmail! : username], id: "")
//            self.navigationController?.pushViewController(vc, animated: true)

        }
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }


}

extension NewGroupViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "group picture", message: "choose a photo from:", preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))

        actionSheet.addAction(UIAlertAction(title: "take a photo", style: .default, handler: { [weak self] (_) in
            self?.presentCamera()
        }))

        actionSheet.addAction(UIAlertAction(title: "choose a photo", style: .default, handler: { [weak self] (_) in
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

