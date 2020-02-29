//
//  HomeTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/29.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        captionLabel.text = post?.caption
        if let photoUrlString = post?.contentImageUrl {
            let photoUrl = URL(string: photoUrlString)
            contentImage.sd_setImage(with: photoUrl, completed: nil)
        }
        setupUserInfo()
    }

    func setupUserInfo() {
        if let uid = post?.uid {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String: Any] {
                    let user = User.transformUser(dict: dict)
                    self.usernameLabel.text = user.username
                    if let photoUrlString = user.profileImageUrl {
                        let photoUrl = URL(string: photoUrlString)
                        self.profileImage.sd_setImage(with: photoUrl, completed: nil)
                    }
                }
            }
        }
    }
            
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 20
        contentImage.layer.cornerRadius = 20
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = UIImage(named: "placeholderImg")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func commentBtnDidTapped(_ sender: Any) {
    }
    @IBAction func likeBtnDidTapped(_ sender: Any) {
    }
    @IBAction func shereBtnDidTapped(_ sender: Any) {
    }
    
}
