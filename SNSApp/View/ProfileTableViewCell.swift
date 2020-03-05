//
//  ProfileTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/04.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followCountLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var selfIntroLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 40
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.borderWidth = 4
        changeButton.layer.cornerRadius = 14
        changeButton.layer.borderColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1).cgColor
        changeButton.layer.borderWidth = 1
        selfIntroLabel.text = ""
        birthdayLabel.text = ""
        dateOfBirthLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}