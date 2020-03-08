//
//  Post_CommentApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/02.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class Post_CommentApi {
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
    func fetchCountComment(postId: String, completion: @escaping (Int) -> Void) {
        REF_POST_COMMENTS.child(postId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
}
