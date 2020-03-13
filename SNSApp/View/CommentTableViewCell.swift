//
//  CommentTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/01.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    var commentVC: CommentViewController?
    var comment: Comment? {
        didSet {
            updateView()
        }
    }
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func updateView() {
        captionLabel?.text = comment?.commentText
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        accountLabel.text = user?.account
        if let photoUrlString = user?.profileImageUrl {
            profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 20
        
        let tapGestureForProfile  = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTap))
        profileImage.addGestureRecognizer(tapGestureForProfile)
        let tapGestureForUsername  = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabelTap))
        usernameLabel.addGestureRecognizer(tapGestureForUsername)
    }
    
    @objc func profileImageTap() {
        if let id = user?.id {
            commentVC?.performSegue(withIdentifier: "OtherVC", sender: id)
        }
    }
    
    @objc func usernameLabelTap() {
        if let id = user?.id {
            commentVC?.performSegue(withIdentifier: "OtherVC", sender: id)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
