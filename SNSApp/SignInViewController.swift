//
//  SignInViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

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
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        
        faceBookButton.setImage(UIImage(named: "icon-facebook"), for: UIControl.State.normal)
        faceBookButton.imageView?.contentMode = .scaleAspectFit
        
        googleButton.setImage(UIImage(named: "icon-google"), for: UIControl.State.normal)
        googleButton.imageView?.contentMode = .scaleAspectFit
        googleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
    }
    
    
    
    @IBAction func forgotPassword(_ sender: Any) {
        
    }
    
    @IBAction func loginBtnDidTapped(_ sender: Any) {
        
    }
    
    @IBAction func fbBtnDidTapped(_ sender: Any) {
        
    }
    @IBAction func googleBtnDidTapped(_ sender: Any) {
        
    }
    

}
