//
//  FollowerTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/16.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase

class FollowerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var selfIntroLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: ProfileViewDelegate?
    var followerVC: FollowerViewController?
    var otherFollowerVC: OtherFollowerViewController?
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        accountLabel.text = user?.account
        selfIntroLabel.text = user?.selfIntro
        if let photoUrlString = user?.profileImageUrl {
            profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
        }
        
        if user?.isFollowing == true {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.text = ""
        accountLabel.text = ""
        selfIntroLabel.text = ""
        profileImage.layer.cornerRadius = 25
        followButton.layer.cornerRadius = 14
        followButton.layer.borderColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1).cgColor
        followButton.layer.borderWidth = 1
        
        let tapGestureForProfileImg = UITapGestureRecognizer(target: self, action: #selector(self.toOtherVC))
        profileImage.addGestureRecognizer(tapGestureForProfileImg)
        let tapGestureForLbl = UITapGestureRecognizer(target: self, action: #selector(self.toOtherVC))
        usernameLabel.addGestureRecognizer(tapGestureForLbl)
    }
    
    func configureFollowButton() {
        followButton.backgroundColor = UIColor.clear
        followButton.setTitleColor(UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1), for: UIControl.State.normal)
        followButton.setTitle("フォローする", for: UIControl.State.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    func configureUnFollowButton() {
        followButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1)
        followButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        followButton.setTitle("フォロー中", for: UIControl.State.normal)
        followButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func followAction() {
        if user?.isFollowing == false {
            FollowApi().followAction(withUser: user!.id)
            configureUnFollowButton()
            user?.isFollowing = true
            
            let timestamp = Int(Date().timeIntervalSince1970)
            let newFollowerId = FollowApi().REF_FOLLOWERS.childByAutoId().key
            
            let newNotiId = NotificationApi().REF_NOTIFICATION.child(user!.id).childByAutoId().key
            let newNotiReference = NotificationApi().REF_NOTIFICATION.child(user!.id).child(newNotiId!)
            newNotiReference.setValue(["from": Auth.auth().currentUser!.uid, "objectId": newFollowerId!,"type": "follower", "timestamp": timestamp])
        }
    }
    
    @objc func unFollowAction() {
        if user?.isFollowing == true {
            let alert: UIAlertController = UIAlertController(title: "フォロー解除しますか？", message: "", preferredStyle: .actionSheet)
            let unFollow: UIAlertAction = UIAlertAction(title: "\(user!.username)のフォローを解除", style: UIAlertAction.Style.default) { (alert) in
                FollowApi().unFollowAction(withUser: self.user!.id)
                self.configureFollowButton()
                self.user?.isFollowing = false
            }
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
            }
            alert.addAction(unFollow)
            alert.addAction(cancel)
            followerVC?.present(alert,animated: true,completion: nil)
            otherFollowerVC?.present(alert,animated: true,completion: nil)
        }
    }
    
    @objc func toOtherVC() {
        if let id = user?.id {
            followerVC?.performSegue(withIdentifier: "OtherVC", sender: id)
            otherFollowerVC?.performSegue(withIdentifier: "OtherVC", sender: id)
        }
    }

}
