//
//  SignUpViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        let descriptionTitle = "新しいアカウントのユーザー情報を作成してください。プロフィール画像、ユーザーネーム、Emailアドレスはいつでも変更できます。"
        let attributedText = NSMutableAttributedString(string: descriptionTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        descriptionLabel.numberOfLines = 0
        descriptionLabel.attributedText = attributedText
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.clipsToBounds = true
        
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
    }
    
    @IBAction func signUpBtnDidTapped(_ sender: Any) {
        
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
