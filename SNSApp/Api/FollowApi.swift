//
//  FollowApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase
class FollowApi {
    var REF_FOLLOWERS = Database.database().reference().child("followers")
    var REF_FOLLOWING = Database.database().reference().child("following")
    var currentUserId = Auth.auth().currentUser!.uid
    
    func observeFollowers(withUser id: String, completion: @escaping (User) -> Void) {
        REF_FOLLOWERS.child(id).observe(.childAdded) { (snapshot) in
            let key = snapshot.key
            UserApi().observeFollowUser(withId: key) { (user) in
                completion(user)
            }
        }
    }
    
    func observeFollowing(withUser id: String, completion: @escaping (User) -> Void) {
        REF_FOLLOWING.child(id).observe(.childAdded) { (snapshot) in
            let key = snapshot.key
            UserApi().observeFollowUser(withId: key) { (user) in
                completion(user)
            }
        }
    }
    
    func observeFollowRemove(withUser id: String, completion: @escaping (User) -> Void) {
        REF_FOLLOWING.child(id).observe(.childRemoved) { (snapshot) in
            let key = snapshot.key
            UserApi().observeFollowUser(withId: key) { (user) in
                completion(user)
            }
        }
    }
    
    func followAction(withUser id: String) {
        MyPostApi().REF_MYPOSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(self.currentUserId).child(key).setValue(true)
                }
            }
        }
        FollowApi().REF_FOLLOWERS.child(id).child(currentUserId).setValue(true)
        FollowApi().REF_FOLLOWING.child(currentUserId).child(id).setValue(true)
    }
    
    func unFollowAction(withUser id: String) {
        MyPostApi().REF_MYPOSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(self.currentUserId).child(key).removeValue()
                }
            }
        }
        FollowApi().REF_FOLLOWERS.child(id).child(currentUserId).setValue(NSNull())
        FollowApi().REF_FOLLOWING.child(currentUserId).child(id).setValue(NSNull())
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        REF_FOLLOWERS.child(userId).child(currentUserId).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        }
    }
    
    func fetchCountFollowers(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWERS.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
    func fetchCountFollowing(userId: String, completion: @escaping (Int) -> Void) {
        REF_FOLLOWING.child(userId).observe(.value) { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }
    }
    
}
