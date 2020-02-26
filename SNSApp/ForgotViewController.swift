//
//  ForgotViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    func setupUI() {
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
    
   
}
