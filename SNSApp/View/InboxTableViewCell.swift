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
    
    @IBOutlet weak var onlineView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var inboxChangeOnlineHandle: DatabaseHandle!
    var inboxChangeMessageHandle: DatabaseHandle!
    var inboxVC: InboxViewController?
    var message: Message?
    var user: User!
    var inbox: Inbox? {
        didSet {
            setupUserInfo()
        }
    }
    
    func setupUserInfo() {
        self.user = inbox?.user
        usernameLabel.text = inbox?.user.username
        accountLabel.text = inbox?.user.account
        let photoUrlString = inbox!.user.profileImageUrl
        profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
        
        let date = Date(timeIntervalSince1970: inbox!.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        
        if !inbox!.messageText.isEmpty {
            messageLabel.text = inbox?.messageText
        } else {
            messageLabel.text = "画像が届いています"
        }
        
        let refOnline = UserApi().REF_USERS.child((inbox?.user.uid)!).child("isOnline")
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? [String: Any] {
                if let active = snap["online"] as? Bool {
                    self.onlineView.backgroundColor = active == true ? .green : .red
                }
            }
        }
        if inboxChangeOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangeOnlineHandle)
        }
        inboxChangeOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.onlineView.backgroundColor = (snap as! Bool) == true ? .green : .red
                }
            }
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
        onlineView.layer.cornerRadius = 15/2
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.backgroundColor = UIColor.red
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let refInbox = InboxApi().REF_INBOX.child(Auth.auth().currentUser!.uid).child((inbox?.user.uid)!)
        if inboxChangeMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangeMessageHandle)
        }
        let refOnline = UserApi().REF_USERS.child((inbox?.user.uid)!).child("isOnline")
        if inboxChangeOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangeOnlineHandle)
        }
    }
    
}
