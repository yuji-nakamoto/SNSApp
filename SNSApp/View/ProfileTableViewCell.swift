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
        selfIntroLabel.text = user?.selfIntro
        if let dateOfBirth = dateOfBirthLabel.text, !dateOfBirth.isEmpty {
            birthdayLabel.text = "生年月日"
        }
        dateOfBirthLabel.text = user?.birthday
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, completed: nil)
        }
        if let photoUrlString = user?.headerImageUrl {
            let photoUrl = URL(string: photoUrlString)
            headerImage.sd_setImage(with: photoUrl, completed: nil)
        }
        FollowApi().fetchCountFollowers(userId: user!.id!) { (count) in
            self.followerCountLabel.text = "\(count)"
        }
        FollowApi().fetchCountFollowing(userId: user!.id!) { (count) in
            self.followCountLabel.text = "\(count)"
        }
        if user?.id == Auth.auth().currentUser?.uid {
            changeButton.setTitle("  変更  ", for: UIControl.State.normal)
            changeButton.addTarget(self, action: #selector(self.toEditVC), for: UIControl.Event.touchUpInside)
        } else {
            updateStateFollowButton()
        }
        
    }
    
    func updateStateFollowButton() {
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
        otherVC?.performSegue(withIdentifier: "EditVC", sender: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.image = UIImage(named: "placeholderImg")
        profileImage.layer.cornerRadius = 40
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 4
        changeButton.layer.cornerRadius = 14
        changeButton.layer.borderColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1).cgColor
        changeButton.layer.borderWidth = 1
        usernameLabel.text = ""
        selfIntroLabel.text = ""
        dateOfBirthLabel.text = ""
        birthdayLabel.text = ""
    }

}
