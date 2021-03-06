//
//  User.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
class User {
    var uid: String
    var account: String
    var email: String
    var profileImageUrl: String
    var username: String
    var id: String
    var birthday: String
    var selfIntro: String
    var headerImageUrl: String
    var isFollowing: Bool
    
    init(uid: String, account: String, email: String, profileImageUrl: String, username: String, id: String, birthday: String, selfIntro: String, headerImageUrl: String, isFollowing: Bool) {
        self.id = id
        self.uid = uid
        self.account = account
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.username = username
        self.birthday = birthday
        self.selfIntro = selfIntro
        self.headerImageUrl = headerImageUrl
        self.isFollowing = isFollowing
    }
    
    static func transformUser(dict: [String: Any], key: String) -> User? {
        let uid = dict["uid"] as? String == nil ? "" : dict["uid"]! as! String
        let username = dict["username"] as? String == nil ? "" : dict["username"]! as! String
        let email = dict["email"] as? String == nil ? "" : dict["email"]! as! String
        let profileImageUrl = dict["profileImageUrl"] as? String == nil ? "" : dict["profileImageUrl"]! as! String
        let account = dict["account"] as? String == nil ? "" : dict["account"]! as! String
        let selfIntro = dict["selfIntro"] as? String == nil ? "" : dict["selfIntro"]! as! String
        let birthday = dict["birthday"] as? String == nil ? "" : dict["birthday"]! as! String
        let headerImageUrl = dict["headerImageUrl"] as? String == nil ? "" : dict["headerImageUrl"]! as! String
        let isFollowing = dict["isFollowing"] as? Bool == nil ? true : dict["isFollowing"]! as! Bool
        
        let user = User(uid: uid, account: account, email: email, profileImageUrl: profileImageUrl, username: username, id: key, birthday: birthday, selfIntro: selfIntro, headerImageUrl: headerImageUrl, isFollowing: isFollowing)
        return user
    }
}
