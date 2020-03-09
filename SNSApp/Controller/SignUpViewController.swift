//
//  SignUpViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
class SignUpViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var accountTextField: UITextField!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupProfileImage()
    }
    
    func setupUI() {
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        let descriptionTitle = "新しいアカウントのユーザー情報を作成してください。プロフィール画像、ユーザーネーム、アカウント名、メールアドレスはいつでも変更できます。"
        let attributedText = NSMutableAttributedString(string: descriptionTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        descriptionLabel.numberOfLines = 0
        descriptionLabel.attributedText = attributedText
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.clipsToBounds = true
    }
    
    func setupProfileImage() {
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        profileImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        profileImage.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpBtnDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        guard let username = self.usernameTextField.text, !username.isEmpty else {
            ProgressHUD.showError("ユーザーネームを入力してください")
            return
        }
        guard let account = self.accountTextField.text, !account.isEmpty else {
            ProgressHUD.showError("アカウント名を入力してください")
            return
        }
        guard let email = self.emailTextField.text, !email.isEmpty else {
            ProgressHUD.showError("メールアドレスを入力してください")
            return
        }
        guard let imageSelected = self.image else {
            ProgressHUD.showError("プロフィール画像を設定してください")
            return
        }
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.5) else {
            return
        }
        ProgressHUD.show()
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            if let authData = result {
                var dict: Dictionary<String, Any> = [
                    "uid": authData.user.uid,
                    "username" : username,
                    "username_lowercase": username.lowercased(),
                    "email" : email,
                    "profileImageUrl" : "",
                    "account": "@\(account)"
                ]
                
                let storageRef = Storage.storage().reference(forURL: "gs://snsapp-bc1d9.appspot.com/")
                let storageProfileRef = storageRef.child("profile").child(authData.user.uid)
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                storageProfileRef.putData(imageData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                        return
                    }
                    storageProfileRef.downloadURL { (url, error) in
                        if let imageUrl = url?.absoluteString {
                            
                            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                                changeRequest.photoURL = url
                                changeRequest.displayName = username
                                changeRequest.commitChanges { (error) in
                                    if let error = error {
                                        ProgressHUD.showError(error.localizedDescription)
                                    }
                                }
                            }
                            
                            dict["profileImageUrl"] = imageUrl
                            
                            Database.database().reference().child("users").child(authData.user.uid).updateChildValues(dict) { (error, ref) in
                                if error == nil {
                                    ProgressHUD.showSuccess()
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                                    self.present(tabBarVC, animated: true, completion: nil)

                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[.editedImage] as? UIImage {
            image = imageSelected
            profileImage.image = imageSelected
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
