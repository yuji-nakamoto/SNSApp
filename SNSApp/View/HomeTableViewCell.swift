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
    @IBOutlet weak var commentButton: UIButton!
    
    var homeVC: HomeViewController?
    var post: Post? {
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
        captionLabel.text = post?.caption
        if let photoUrlString = post?.contentImageUrl {
            let photoUrl = URL(string: photoUrlString)
            contentImage.sd_setImage(with: photoUrl, completed: nil)
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
        profileImage.layer.cornerRadius = 20
        contentImage.layer.cornerRadius = 20
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.contentImageTap))
               contentImage.addGestureRecognizer(tapGesture)
        let tapGestureForBtn = UITapGestureRecognizer(target: self, action: #selector(self.commentBtnTap))
        commentButton.addGestureRecognizer(tapGestureForBtn)
        
    }
    
    @objc func contentImageTap() {
        if let id = post?.id {
           homeVC?.performSegue(withIdentifier: "CommentVC", sender: id)
        }
    }
    
    @objc func commentBtnTap() {
        if let id = post?.id {
            homeVC?.performSegue(withIdentifier: "CommentVC", sender: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = UIImage(named: "placeholderImg")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func likeBtnDidTapped(_ sender: Any) {
    }
    @IBAction func shereBtnDidTapped(_ sender: Any) {
    }
    
}
