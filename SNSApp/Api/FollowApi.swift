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
    
    func followAction(withUser id: String) {
        MyPostApi().REF_MYPOSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Auth.auth().currentUser!.uid).child(key).setValue(true)
                }
            }
        }
        
        FollowApi().REF_FOLLOWERS.child(id).child(Auth.auth().currentUser!.uid).setValue(true)
        FollowApi().REF_FOLLOWING.child(Auth.auth().currentUser!.uid).child(id).setValue(true)
    }
    
    func unFollowAction(withUser id: String) {
        MyPostApi().REF_MYPOSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for key in dict.keys {
                    Database.database().reference().child("feed").child(Auth.auth().currentUser!.uid).child(key).removeValue()
                }
            }
        }
        
        FollowApi().REF_FOLLOWERS.child(id).child(Auth.auth().currentUser!.uid).setValue(NSNull())
        FollowApi().REF_FOLLOWING.child(Auth.auth().currentUser!.uid).child(id).setValue(NSNull())
        
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        REF_FOLLOWERS.child(userId).child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                completed(false)
            } else {
                completed(true)
            }
        }
    }
    
}
