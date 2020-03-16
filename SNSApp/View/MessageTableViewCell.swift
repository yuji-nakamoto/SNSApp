//
//  MessageTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/11.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var bubleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubleRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubleLeftConstraint: NSLayoutConstraint!
    
    var user: User?
    var message: Message? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = 18
        bubleView.layer.cornerRadius = 15
        bubleView.layer.borderWidth = 1
        photoImage.layer.cornerRadius = 15
                
        photoImage.isHidden = true
        profileImage.isHidden = true
        messageLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.isHidden = true
        profileImage.isHidden = true
        messageLabel.isHidden = true
    }
    
    func updateView() {
        let text = message!.messageText
        if !text!.isEmpty {
            messageLabel.isHidden = false
            messageLabel.text = message!.messageText
            
            let widthValue = text!.estimateFrameForText_1(text!).width + 40
            if widthValue < 100 {
                widthConstraint.constant = 100
            } else {
                widthConstraint.constant = widthValue
            }
            dateLabel.textColor = .lightGray
        } else {
            dateLabel.textColor = .white
            photoImage.isHidden = false
            if let photoUrlString = message!.imageUrl {
                photoImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
            }
            bubleView.layer.borderColor = UIColor.clear.cgColor
            dateLabel.textColor = .white
            widthConstraint.constant = 250
        }
        
        if Auth.auth().currentUser!.uid == message!.from {
            bubleView.backgroundColor = UIColor.systemGroupedBackground
            bubleView.layer.borderColor = UIColor.clear.cgColor
            bubleRightConstraint.constant = 8
            bubleLeftConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubleRightConstraint.constant
        } else {
            profileImage.isHidden = false
            bubleView.backgroundColor = UIColor.white
            if let photoUrlString = user?.profileImageUrl {
                profileImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
            }
            bubleView.layer.borderColor = UIColor.lightGray.cgColor
            bubleLeftConstraint.constant = 55
            bubleRightConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubleLeftConstraint.constant
        }
        
        let date = Date(timeIntervalSince1970: message!.date!)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        self.formatHeaderTimeLabel(time: date) { (text) in
            self.timeLabel.text = text
        }
        
    }
    
    func formatHeaderTimeLabel(time: Date, comletion: @escaping (String) -> ()) {
        var text = ""
        let currentDate = Date()
        let currentDateString = currentDate.toString(dateFormat: "yyyymmdd")
        let pastDateString = time.toString(dateFormat: "yyyymmdd")
        
        if pastDateString.elementsEqual(currentDateString) == true {
            text = time.toString(dateFormat: "HH:mm a") + ", 今日"
        } else {
            text = time.toString(dateFormat: "MM/dd/yyyy")
        }
        comletion(text)
    }
    
}
