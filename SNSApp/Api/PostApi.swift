//
//  PostApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/01.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase
class PostApi {
    var REF_POSTS = Database.database().reference().child("posts")
    
    func observePosts(comletion: @escaping (Post) -> Void) {
        REF_POSTS.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPost(dict: dict, key: snapshot.key)
                comletion(newPost)
            }
        }
    }
    
    func observePost(withId id: String, comletion: @escaping (Post) -> Void) {
        REF_POSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let post = Post.transformPost(dict: dict, key: snapshot.key)
                comletion(post)
            }
        }
    }
    
}
