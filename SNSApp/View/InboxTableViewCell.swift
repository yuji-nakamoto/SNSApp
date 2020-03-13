//
//  InboxTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/11.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase

class InboxTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var inboxChangeMessageHandle: DatabaseHandle!
    var inboxVC: InboxViewController?
    var user: User?
    var inbox: Inbox? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        usernameLabel.text = inbox?.user.username
        accountLabel.text = inbox?.user.account
        if let photoUrlString = inbox!.user.profileImageUrl {
            profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
        }
        let date = Date(timeIntervalSince1970: inbox!.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        
        if !inbox!.messageText.isEmpty {
            messageLabel.text = inbox?.messageText
        } else {
            messageLabel.text = "画像が届いています"
        }
        
        let refInbox = InboxApi().REF_INBOX.child(Auth.auth().currentUser!.uid).child((inbox?.user.uid)!)
        if inboxChangeMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangeMessageHandle)
        }
        inboxChangeMessageHandle = refInbox.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value {
                self.inbox?.updateData(key: snapshot.key, value: snap)
                self.inboxVC?.sortMessage()
            }
        })
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 25
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTap))
        addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let refInbox = InboxApi().REF_INBOX.child(Auth.auth().currentUser!.uid).child((inbox?.user.uid)!)
        if inboxChangeMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangeMessageHandle)
        }
    }
    
    @objc func cellTap() {
        if let id = inbox!.user.id {
            inboxVC?.performSegue(withIdentifier: "MessageVC", sender: id)
        }
    }
    
}
