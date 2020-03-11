//
//  InboxTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/11.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var inboxVC: InboxViewController?
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        usernameLabel.text = user?.username
        accountLabel.text = user?.account
        if let photoUrlString = user?.profileImageUrl {
            profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
        }
        let dateformattar = DateFormatter()
        dateformattar.timeStyle = .none
        dateformattar.dateStyle = .long
        dateformattar.locale = Locale(identifier: "ja_JP")
        let now = Date()
        dateLabel.text = dateformattar.string(from: now)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 25
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func cellTap() {
        if let id = user?.id {
            inboxVC?.performSegue(withIdentifier: "MessageVC", sender: id)
        }
    }
    
}
