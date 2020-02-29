//
//  Post.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/29.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation

class Post {
    var caption: String?
    var contentImageUrl: String?
    var uid: String?
}

extension Post {
    static func transformPost(dict: [String: Any]) -> Post {
        let post = Post()
        
        post.uid = dict["uid"] as? String
        post.caption = dict["caption"] as? String
        post.contentImageUrl = dict["contentImageUrl"] as? String
        return post
        
    }
}
