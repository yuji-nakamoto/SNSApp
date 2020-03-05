//
//  SideMenuViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/02.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class SideMenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var toLogoutLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        updateView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.logoutLabelTap))
        toLogoutLabel.addGestureRecognizer(tapGesture)
    }
    
    func updateView() {
        usernameLabel.text = " "
        profileImage.layer.cornerRadius = 30
        UserApi().REF_CURRENT_USER?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                self.usernameLabel.text = user.username
                if let photoUrlString = user.profileImageUrl {
                    let photoUrl = URL(string: photoUrlString)
                    self.profileImage.sd_setImage(with: photoUrl, completed: nil)
                }
            }
        })
    }
    
    @IBAction func toProfileVC(_ sender: Any) {
        performSegue(withIdentifier: "ProfileVC", sender: nil)
    }
    
    
    @objc func logoutLabelTap() {
        let alert: UIAlertController = UIAlertController(title: "Log Out", message: "本当にログアウトしますか？", preferredStyle: .actionSheet)
        let logout: UIAlertAction = UIAlertAction(title: "ログアウト", style: UIAlertAction.Style.default) { (alert) in
            do {
                try Auth.auth().signOut()
            } catch  {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInVC")
            self.present(signInVC, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
        }
        alert.addAction(logout)
        alert.addAction(cancel)
        self.present(alert,animated: true,completion: nil)
    }
    
    
    

}

extension SideMenuViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell") as! SideMenuTableViewCell

        return cell
    }


}