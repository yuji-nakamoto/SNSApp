//
//  ForgotViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class ForgotViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI() {
        emailTextField.delegate = self
        let descriptionTitle = "パスワードをリセットするため、登録したEmailアドレスを入力してください。"
        let attributedText = NSMutableAttributedString(string: descriptionTitle, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15),NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        descriptionLabel.numberOfLines = 0
        descriptionLabel.attributedText = attributedText
        
        resetButton.layer.cornerRadius = 5
        resetButton.clipsToBounds = true
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBAction func resetAction(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            ProgressHUD.showError("Emailアドレスを入力してください")
            return
        }
        ProgressHUD.show()
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
            if error == nil {
                self.view.endEditing(true)
                ProgressHUD.showSuccess("パスワードをリセットするメールを送信しました。メールを確認してください。")
                self.navigationController?.popViewController(animated: true)
                
            } else {
                ProgressHUD.showError(error?.localizedDescription)
            }
        }
    }
    
}
