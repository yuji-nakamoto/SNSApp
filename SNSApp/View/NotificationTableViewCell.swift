//
//  NotificationTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/09.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var notiVC: NotificationViewController?
    var notification: NotificationModel? {
        didSet {
            updateView()
        }
    }
    
    var user: User? {
        didSet {
            setupUserInfo()
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        FollowApi().isFollowing(userId: userId, completed: completed)
    }
    
    func updateView() {
        switch notification?.type {
        case "feed":
            
            let postId = notification!.objectId!
            PostApi().observePost(withId: postId) { (post) in
                self.descriptionLabel.text = "新しい投稿です \(post.caption!)"
            }
        case "follower":
            descriptionLabel.text = "\(user!.username!)さんがフォローしました"
        default:
            break
        }
        if let timestamp = notification?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "・今"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "・\(diff.second!) 秒前"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "・\(diff.minute!) 分前"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "・\(diff.hour!) 時間前"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "・\(diff.day!) 日前"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "・\(diff.weekOfMonth!) 週前"
            }
            dateLabel.text = timeText
        }
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
        descriptionLabel.text = ""
        usernameLabel.text = ""
        dateLabel.text = ""
        profileImage.layer.cornerRadius = 25
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cellTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc func cellTap() {
        switch notification?.type {
        case "feed":
            if let id = notification?.objectId {
                notiVC?.performSegue(withIdentifier: "CommentVC", sender: id)
            }
        case "follower":
            if let id = user?.id {
                notiVC?.performSegue(withIdentifier: "OtherVC", sender: id)
            }
        default:
            break
        }
    }
    
}
