//
//  FeedApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class FeedApi {
    var REF_FEED = Database.database().reference().child("feed")
    
    func observeFeed(withId id: String, completion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observe(.childAdded) { (snapshot) in
            let key = snapshot.key
            PostApi().observePost(withId: key) { (post) in
                completion(post)
            }
        }
    }
    
    func observeFeedRemove(withId id: String, comletion: @escaping (Post) -> Void) {
        REF_FEED.child(id).observe(.childRemoved) { (snapshot) in
            let key = snapshot.key
            PostApi().observePost(withId: key) { (post) in
                comletion(post)
            }
        }
    }
    
    func sendFeed(withUser id: String) {
        MyPostApi().REF_MYPOSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Auth.auth().currentUser!.uid).child(key).setValue(true)
                }
            }
        }
    }
    
}
