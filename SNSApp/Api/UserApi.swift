//
//  UserApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/01.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase
class UserApi {
    var REF_USERS
        = Database.database().reference().child("users")
    
    func observeUser(withId uid: String, comletion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                comletion(user!)
            }
        }
    }
    
    func observeFollowUser(withId uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                if user?.id != Auth.auth().currentUser!.uid {
                    completion(user!)
                }
            }
        }
    }
    
    func observeCurrentUser(comletion: @escaping (User) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                comletion(user!)
            }
        }
    }
    
    func observeUsers(completion: @escaping (User) -> Void) {
        REF_USERS.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                if user?.id != Auth.auth().currentUser!.uid {
                    completion(user!)
                }
            }
        }
    }
    
    func getUserInfo(uid: String, completion: @escaping (User) -> Void) {
        REF_USERS.child(uid).observe(.value) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = User.transformUser(dict: dict, key: snapshot.key)
                completion(user!)
            }
        }
    }
    
    func saveUserProfile(dict: [String: Any], onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        REF_USERS.child(currentUser.uid).updateChildValues(dict) { (error, dataRef) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func queryUsers(withText text: String, completion: @escaping (User) -> Void) {
        REF_USERS.queryOrdered(byChild: "username_lowercase").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach { (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let user = User.transformUser(dict: dict, key: child.key)
                    if user?.id != Auth.auth().currentUser!.uid {
                        completion(user!)
                    }
                }
            }
        }
    }
    
    func queryAccounts(withText text: String, completion: @escaping (User) -> Void) {
        REF_USERS.queryOrdered(byChild: "account").queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}").queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
            snapshot.children.forEach { (s) in
                let child = s as! DataSnapshot
                if let dict = child.value as? [String: Any] {
                    let user = User.transformUser(dict: dict, key: child.key)
                    if user?.id != Auth.auth().currentUser!.uid {
                        completion(user!)
                    }
                }
            }
        }
    }
    
    var REF_CURRENT_USER: DatabaseReference? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        return REF_USERS.child(currentUser.uid)
    }
    
    func isOnline(bool: Bool) {
        if let currentUserId = Auth.auth().currentUser?.uid, !currentUserId.isEmpty {
            let ref = REF_USERS.child(Auth.auth().currentUser!.uid).child("isOnline")
            let dict: [String: Any] = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func typing(from: String, to: String) {
        let ref = REF_USERS.child(from).child("isOnline")
        let dict: [String: Any] = [
            "typing": to
        ]
        ref.updateChildValues(dict)
    }
}
