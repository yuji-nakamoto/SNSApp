//
//  SearchTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: ProfileViewDelegate?
    var searchVC: SearchViewController?
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImage.sd_setImage(with: photoUrl, completed: nil)
        }
        
        if user?.isFollowing == true {
            configureUnFollowButton()
        } else {
            configureFollowButton()
        }
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
            FollowApi().followAction(withUser: user!.id!)
            configureUnFollowButton()
            user?.isFollowing = true
        }
    }
    
    @objc func unFollowAction() {
        if user?.isFollowing == true {
            let alert: UIAlertController = UIAlertController(title: "フォロー解除しますか？", message: "", preferredStyle: .actionSheet)
            
            let unFollow: UIAlertAction = UIAlertAction(title: "\(user!.username!)のフォローを解除", style: UIAlertAction.Style.default) { (alert) in
                FollowApi().unFollowAction(withUser: self.user!.id!)
                self.configureFollowButton()
                self.user?.isFollowing = false
            }
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
            }
            alert.addAction(unFollow)
            alert.addAction(cancel)
            searchVC?.present(alert,animated: true,completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 30
        usernameLabel.text = ""
        followButton.layer.cornerRadius = 14
        followButton.layer.borderColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1).cgColor
        followButton.layer.borderWidth = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTap))
        profileImage.addGestureRecognizer(tapGesture)
        let tapGestureForLbl = UITapGestureRecognizer(target: self, action: #selector(self.usernameLblTap))
        usernameLabel.addGestureRecognizer(tapGestureForLbl)
    }
    
    @objc func profileImageTap() {
        if let id = user?.id {
            searchVC?.performSegue(withIdentifier: "OtherVC", sender: id)
        }
    }
    
    @objc func usernameLblTap() {
        if let id = user?.id {
            searchVC?.performSegue(withIdentifier: "OtherVC", sender: id)
        }
    }
    
}
