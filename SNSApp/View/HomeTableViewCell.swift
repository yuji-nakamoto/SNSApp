//
//  HomeTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/29.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import Lottie

class HomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var animationView: AnimationView! = AnimationView()
    var postRef: DatabaseReference!
    var homeVC: HomeViewController?
    var profileVC: ProfileViewController?
    var otherVC: OtherProfileViewController?
    
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
        let caption = post?.caption
        let imageUrl = post?.imageUrl
        if !caption!.isEmpty && imageUrl == nil {
            captionLabel.text = caption
        } else {
            captionLabel.text = caption
            contentImage.isHidden = false
            contentImage.sd_setImage(with: URL(string: imageUrl!), completed: nil)
        }
        
        PostApi().REF_POSTS.child(post!.id!).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                self.updateLike(post: post)
            }
        }
        PostApi().REF_POSTS.child(post!.id!).observe(.childChanged) { (snapshot) in
            if let value = snapshot.value as? Int {
                self.likeCountLabel.text = "\(value)"
            }
        }
        Post_CommentApi().fetchCountComment(postId: post!.id!) { (count) in
            self.commentCountLabel.text = "\(count)"
        }
        
        if let timestamp = post?.timestamp {
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "今"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = "\(diff.second!) 秒前"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = "\(diff.minute!) 分前"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = "\(diff.hour!) 時間前"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = "\(diff.day!) 日前"
            }
            if diff.weekOfMonth! > 0 {
                timeText = "\(diff.weekOfMonth!) 週前"
            }
            dateLabel.text = timeText
        }
    }
    
    func updateLike(post: Post) {
        let imageName = post.likes == nil || !post.isLiked! ? "like" : "likeSelected"
        likeImage.image = UIImage(named: imageName)
        guard let count = post.likeCount else {
            return
        }
        if count != 0 {
            likeCountLabel.text = "\(count)"
            likeCountLabel.textColor = UIColor.red
        } else {
            likeCountLabel.text = "0"
            likeCountLabel.textColor = UIColor.lightGray
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
        profileImage.layer.cornerRadius = 20
        contentImage.layer.cornerRadius = 20
        contentImage.image = nil
        contentImage.isHidden = true
        captionLabel.isHidden = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.contentImageTap))
        contentImage.addGestureRecognizer(tapGesture)
        let tapGestureForBtn = UITapGestureRecognizer(target: self, action: #selector(self.commentBtnTap))
        commentButton.addGestureRecognizer(tapGestureForBtn)
        let tapGestureForLike = UITapGestureRecognizer(target: self, action: #selector(self.likeImageTap))
        likeImage.addGestureRecognizer(tapGestureForLike)
        let tapGestureForProfile  = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTap))
        profileImage.addGestureRecognizer(tapGestureForProfile)
        let tapGestureForUsername  = UITapGestureRecognizer(target: self, action: #selector(self.usernameLabelTap))
        usernameLabel.addGestureRecognizer(tapGestureForUsername)
    }
    
    @objc func likeImageTap() {
        if likeImage.image == UIImage(named: "like") {
            startAnimation()
            postRef = PostApi().REF_POSTS.child(post!.id!)
            incrementLikes(forRef: postRef)
        } else {
            postRef = PostApi().REF_POSTS.child(post!.id!)
            incrementLikes(forRef: postRef)
        }
    }
    
    func incrementLikes(forRef ref: DatabaseReference) {
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                var likes : [String: Bool]
                likes = post["likes"] as? [String: Bool] ?? [:]
                var likeCount = post["likeCount"] as? Int ?? 0
                if let _ = likes[uid] {
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    likeCount += 1
                    likes[uid] = true
                }
                post["likeCount"] = likeCount as AnyObject
                post["likes"] = likes as AnyObject
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if let dict = snapshot?.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot!.key)
                self.updateLike(post: post)
            }
        }
    }
    
    func startAnimation(){
        let animation = Animation.named("heart")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFill
        animationView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        animationView.loopMode = .playOnce
        animationView.backgroundColor = .clear
        self.addSubview(animationView)
        animationView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.animationView.removeFromSuperview()
        }
    }
    
    @objc func contentImageTap() {
        if let id = post?.id {
            homeVC?.performSegue(withIdentifier: "CommentVC", sender: id)
            profileVC?.performSegue(withIdentifier: "CommentVC", sender: id)
            otherVC?.performSegue(withIdentifier: "CommentVC", sender: id)
        }
    }
    
    @objc func commentBtnTap() {
        if let id = post?.id {
            homeVC?.performSegue(withIdentifier: "CommentVC", sender: id)
            profileVC?.performSegue(withIdentifier: "CommentVC", sender: id)
            otherVC?.performSegue(withIdentifier: "CommentVC", sender: id)
        }
    }
    
    @objc func profileImageTap() {
        if let id = user?.id {
            homeVC?.performSegue(withIdentifier: "OtherVC", sender: id)
        }
    }
    
    @objc func usernameLabelTap() {
        if let id = user?.id {
            homeVC?.performSegue(withIdentifier: "OtherVC", sender: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImage.image = nil
        contentImage.isHidden = true
        captionLabel.isHidden = false
    }
    
}
