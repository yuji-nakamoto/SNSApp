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
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var animationView: AnimationView! = AnimationView()
    var postRef: DatabaseReference!
    var homeVC: HomeViewController?
    var profileVC: ProfileViewController?
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
        let tapGestureForLike = UITapGestureRecognizer(target: self, action: #selector(self.likeImageTap))
        likeImage.addGestureRecognizer(tapGestureForLike)
        
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
                var likes : Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
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
        }
    }
    
    @objc func commentBtnTap() {
        if let id = post?.id {
            homeVC?.performSegue(withIdentifier: "CommentVC", sender: id)
            profileVC?.performSegue(withIdentifier: "CommentVC", sender: id)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = UIImage(named: "placeholderImg")
    }
    
    
 
}
