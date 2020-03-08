//
//  Post.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/29.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class Post {
    var caption: String?
    var photoImageUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
}

extension Post {
    static func transformPost(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.uid = dict["uid"] as? String
        post.caption = dict["caption"] as? String
        post.photoImageUrl = dict["photoImageUrl"] as? String
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        if let currentUserId = Auth.auth().currentUser?.uid {
            if post.likes != nil {
                if post.likes![currentUserId] != nil {
                    post.isLiked = true
                } else {
                    post.isLiked = false
                }
            }
        }
        
        return post
        
    }
}
