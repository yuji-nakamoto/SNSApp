//
//  ProfileTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/04.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
protocol ProfileViewDelegate {
    func updateFollowButton(forUser user: User)
}

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var selfIntroLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var delegate: ProfileViewDelegate?
    var otherVC: OtherProfileViewController?
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        accountLabel.text = user?.account
        selfIntroLabel.text = user?.selfIntro
        if let dateOfBirth = dateOfBirthLabel.text, !dateOfBirth.isEmpty {
            birthdayLabel.text = "誕生日"
        }
        dateOfBirthLabel.text = user?.birthday
        if let photoUrlString = user?.profileImageUrl {
            profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
        }
        if let photoUrlString = user?.headerImageUrl {
            headerImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
        }
        FollowApi().fetchCountFollowers(userId: user!.id!) { (count) in
            self.followerCountLabel.text = "\(count)"
        }
        FollowApi().fetchCountFollowing(userId: user!.id!) { (count) in
            self.followCountLabel.text = "\(count)"
        }
        if user?.id == Auth.auth().currentUser?.uid {
            messageButton.isHidden = true
            changeButton.isHidden = false
            changeButton.setTitle("  変更  ", for: UIControl.State.normal)
            changeButton.addTarget(self, action: #selector(self.toEditVC), for: UIControl.Event.touchUpInside)
        } else {
            updateStateFollowButton()
        }
    }
    
    func updateStateFollowButton() {
        messageButton.isHidden = false
        changeButton.isHidden = false
        if user?.isFollowing == true {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
    }
    
    func configureFollowButton() {
        changeButton.backgroundColor = UIColor.clear
        changeButton.setTitleColor(UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1), for: UIControl.State.normal)
        changeButton.setTitle("  フォローする  ", for: UIControl.State.normal)
        changeButton.addTarget(self, action: #selector(self.followAction), for: UIControl.Event.touchUpInside)
    }
    
    func configureUnFollowButton() {
        changeButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1)
        changeButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        changeButton.setTitle("  フォロー中  ", for: UIControl.State.normal)
        changeButton.addTarget(self, action: #selector(self.unFollowAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func followAction() {
        if user?.isFollowing == false {
            FollowApi().followAction(withUser: user!.id!)
            configureUnFollowButton()
            user?.isFollowing = true
            delegate?.updateFollowButton(forUser: user!)
            
            let timestamp = Int(Date().timeIntervalSince1970)
            let newFollowerId = FollowApi().REF_FOLLOWERS.childByAutoId().key
            let newNotiId = NotificationApi().REF_NOTIFICATION.child(user!.id!).childByAutoId().key
            let newNotiReference = NotificationApi().REF_NOTIFICATION.child(user!.id!).child(newNotiId!)
            newNotiReference.setValue(["from": Auth.auth().currentUser!.uid, "objectId": newFollowerId!,"type": "follower", "timestamp": timestamp])
        }
    }
    
    @objc func unFollowAction() {
        if user?.isFollowing == true {
            let alert: UIAlertController = UIAlertController(title: "フォロー解除しますか？", message: "", preferredStyle: .actionSheet)
            
            let unFollow: UIAlertAction = UIAlertAction(title: "\(user!.username!)のフォローを解除", style: UIAlertAction.Style.default) { (alert) in
                FollowApi().unFollowAction(withUser: self.user!.id!)
                self.configureFollowButton()
                self.user?.isFollowing = false
                self.delegate?.updateFollowButton(forUser: self.user!)
            }
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
            }
            alert.addAction(unFollow)
            alert.addAction(cancel)
            otherVC?.present(alert,animated: true,completion: nil)
        }
    }
    
    @objc func toEditVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC") as! EditTableViewController
        otherVC?.navigationController?.pushViewController(editVC, animated: true)
    }
    
    @IBAction func toMessageVC(_ sender: Any) {
        if let id = user?.id {
            otherVC?.performSegue(withIdentifier: "MessageVC", sender: id)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.image = UIImage(named: "placeholderImg")
        profileImage.layer.cornerRadius = 40
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 4
        changeButton.layer.cornerRadius = 15
        changeButton.layer.borderColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1).cgColor
        changeButton.layer.borderWidth = 1
        changeButton.isHidden = true
        messageButton.tintColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1)
        messageButton.isHidden = true
        usernameLabel.text = ""
        selfIntroLabel.text = ""
        dateOfBirthLabel.text = ""
        birthdayLabel.text = ""
        accountLabel.text = ""
    }

}
