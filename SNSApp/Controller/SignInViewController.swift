//
//  SignInViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import FBSDKLoginKit

class SignInViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var faceBookButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

       setupUI()
    }
    
    func setupUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        
        faceBookButton.setImage(UIImage(named: "icon-facebook"), for: UIControl.State.normal)
        faceBookButton.imageView?.contentMode = .scaleAspectFit
        
        googleButton.setImage(UIImage(named: "icon-google"), for: UIControl.State.normal)
        googleButton.imageView?.contentMode = .scaleAspectFit
        googleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBAction func loginBtnDidTapped(_ sender: Any) {
        ProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            ProgressHUD.showSuccess()
            UserApi().isOnline(bool: true)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
            self.present(tabBarVC, animated: true, completion: nil)

        }
    }
    
    @IBAction func fbBtnDidTapped(_ sender: Any) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            guard let accessToken = AccessToken.current else {
                ProgressHUD.showError("Faild to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                if let authData = result {
                    let dict : [String: Any] = [
                        "uid": authData.user.uid,
                        "email": authData.user.email as Any,
                        "username": authData.user.displayName as Any,
                        "username_lowercase": authData.user.displayName?.lowercased() as Any,
                        "profileImageUrl": authData.user.photoURL?.absoluteString as Any,
                        "account": "@\(authData.user.displayName!)"
                    ]
                    UserApi().REF_USERS.child(authData.user.uid).updateChildValues(dict) { (error, ref) in
                        if error == nil {
                            UserApi().isOnline(bool: true)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarVC")
                            self.present(tabBarVC, animated: true, completion: nil)
                        } else {
                            ProgressHUD.showError(error!.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func googleBtnDidTapped(_ sender: Any) {
        
    }
    

}
