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
    var imageUrl: String?
    var uid: String?
    var id: String?
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool?
    var timestamp: Int?
    var height: Double?
    var width: Double?
}

extension Post {
    static func transformPost(dict: [String: Any], key: String) -> Post {
        let post = Post()
        post.id = key
        post.uid = dict["uid"] as? String
        post.caption = dict["caption"] as? String
        post.imageUrl = dict["imageUrl"] as? String
        post.timestamp = dict["timestamp"] as? Int
        post.likeCount = dict["likeCount"] as? Int
        post.likes = dict["likes"] as? Dictionary<String, Any>
        post.height = dict["height"] as? Double == nil ? 0 : dict["height"] as! Double
        post.width = dict["width"] as? Double == nil ? 0 : dict["width"] as! Double
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
