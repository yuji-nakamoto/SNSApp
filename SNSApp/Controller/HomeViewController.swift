//
//  HomeViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInVC")
            self.present(signInVC, animated: true, completion: nil)
        } catch  {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
    }
    
    

}
