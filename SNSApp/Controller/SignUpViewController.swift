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
        let descriptionTitle = "新しいアカウントのユーザー情報を作成してください。プロフィール画像、ユーザーネーム、Emailアドレスはいつでも変更できます。"
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
                    "username" : self.usernameTextField.text,
                    "email" : authData.user.email,
                    "profileImageUrl" : ""
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
                            dict["profileImageUrl"] = imageUrl
                            
                            Database.database().reference().child("users").child(authData.user.uid).updateChildValues(dict) { (error, ref) in
                                if error == nil {
                                    ProgressHUD.showSuccess()
                                    print("done")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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