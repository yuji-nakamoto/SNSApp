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
    
    @IBOutlet weak var logoutIcon: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
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
        
        let tapGestureForLogoutIcon = UITapGestureRecognizer(target: self, action: #selector(self.logoutLabelTap))
        logoutIcon.addGestureRecognizer(tapGestureForLogoutIcon)
        let tapGestureForLogoutLabl = UITapGestureRecognizer(target: self, action: #selector(self.logoutLabelTap))
        toLogoutLabel.addGestureRecognizer(tapGestureForLogoutLabl)
        let tapGestureForProfileIImg  = UITapGestureRecognizer(target: self, action: #selector(self.toProfile))
        profileImage.addGestureRecognizer(tapGestureForProfileIImg)
        let tapGestureForUsernameLbl  = UITapGestureRecognizer(target: self, action: #selector(self.toProfile))
        usernameLabel.addGestureRecognizer(tapGestureForUsernameLbl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func updateView() {
        logoutIcon.tintColor = UIColor.red
        usernameLabel.text = " "
        profileImage.layer.cornerRadius = 30
        UserApi().REF_CURRENT_USER?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                self.usernameLabel.text = user.username
                self.accountLabel.text = user.account
                if let photoUrlString = user.profileImageUrl {
                    self.profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
                    FollowApi().fetchCountFollowers(userId: user.id!) { (count) in
                        self.followerCountLabel.text = "\(count)"
                    }
                    FollowApi().fetchCountFollowing(userId: user.id!) { (count) in
                        self.followCountLabel.text = "\(count)"
                    }
                }
            }
        })
    }
    
    @objc func toProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    @objc func logoutLabelTap() {
        UserApi().observeCurrentUser { (user) in
            let alert: UIAlertController = UIAlertController(title: "\(user.username!)", message: "ログアウトしてもよろしいですか？", preferredStyle: .actionSheet)
            let logout: UIAlertAction = UIAlertAction(title: "ログアウト", style: UIAlertAction.Style.default) { (alert) in
                do {
                    UserApi().isOnline(bool: false)
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
    
}

extension SideMenuViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell") as! SideMenuTableViewCell
        cell.sideMenuVC = self
        return cell
    }
    
    
}
