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
import GoogleSignIn

class SideMenuViewController: UIViewController {
    
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var logoutIcon: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var toLogoutLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.backgroundColor = .secondarySystemGroupedBackground
        
        updateView()
        setupGesture()
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
        logoutIcon.tintColor = UIColor.systemRed
        usernameLabel.text = " "
        profileImage.layer.cornerRadius = 30
        UserApi().REF_CURRENT_USER?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                self.usernameLabel.text = user?.username
                self.accountLabel.text = user?.account
                if let photoUrlString = user?.profileImageUrl {
                    self.profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
                    FollowApi().fetchCountFollowers(userId: user!.id) { (count) in
                        self.followerCountLabel.text = "\(count)"
                    }
                    FollowApi().fetchCountFollowing(userId: user!.id) { (count) in
                        self.followingCountLabel.text = "\(count)"
                    }
                }
            }
        })
    }
    
    func setupGesture() {
        let tapGestureForLogoutIcon = UITapGestureRecognizer(target: self, action: #selector(self.logoutLabelTap))
        logoutIcon.addGestureRecognizer(tapGestureForLogoutIcon)
        let tapGestureForLogoutLabl = UITapGestureRecognizer(target: self, action: #selector(self.logoutLabelTap))
        toLogoutLabel.addGestureRecognizer(tapGestureForLogoutLabl)
        let tapGestureForProfileIImg  = UITapGestureRecognizer(target: self, action: #selector(self.toProfile))
        profileImage.addGestureRecognizer(tapGestureForProfileIImg)
        let tapGestureForUsernameLbl  = UITapGestureRecognizer(target: self, action: #selector(self.toProfile))
        usernameLabel.addGestureRecognizer(tapGestureForUsernameLbl)
        let tapGestureForFollowerLbl  = UITapGestureRecognizer(target: self, action: #selector(self.toFollower))
        followerLabel.addGestureRecognizer(tapGestureForFollowerLbl)
        let tapGestureForFollowerCountLbl  = UITapGestureRecognizer(target: self, action: #selector(self.toFollower))
        followerCountLabel.addGestureRecognizer(tapGestureForFollowerCountLbl)
        let tapGestureForFollowingLbl  = UITapGestureRecognizer(target: self, action: #selector(self.toFollowing))
        followingLabel.addGestureRecognizer(tapGestureForFollowingLbl)
        let tapGestureForFollowingCountLbl  = UITapGestureRecognizer(target: self, action: #selector(self.toFollowing))
        followingCountLabel.addGestureRecognizer(tapGestureForFollowingCountLbl)
    }
    
    @objc func toProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        self.navigationController?.pushViewController(profileVC, animated: false)
    }
    
    @objc func toFollower() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let followerVC = storyboard.instantiateViewController(withIdentifier: "FollowerVC") as! FollowerViewController
        self.navigationController?.pushViewController(followerVC, animated: false)
    }
    
    @objc func toFollowing() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let followingVC = storyboard.instantiateViewController(withIdentifier: "FollowingVC") as! FollowingViewController
        self.navigationController?.pushViewController(followingVC, animated: false)
    }
    
    @objc func logoutLabelTap() {
        UserApi().observeCurrentUser { (user) in
            let alert: UIAlertController = UIAlertController(title: "\(user.username)", message: "ログアウトしてもよろしいですか？", preferredStyle: .actionSheet)
            let logout: UIAlertAction = UIAlertAction(title: "ログアウト", style: UIAlertAction.Style.default) { (alert) in
                do {
                    UserApi().isOnline(bool: false)
                    Messaging.messaging().unsubscribe(fromTopic: Auth.auth().currentUser!.uid)
                    if let providerData = Auth.auth().currentUser?.providerData {
                        let userInfo = providerData[0]
                        
                        switch userInfo.providerID {
                        case "google.com":
                            GIDSignIn.sharedInstance()?.signOut()
                        default:
                            break
                        }
                    }
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
