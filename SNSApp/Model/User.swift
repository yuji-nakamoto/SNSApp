//
//  User.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
class User {
    var account: String?
    var email: String?
    var profileImageUrl: String?
    var username: String?
    var id: String?
    var birthday: String?
    var selfIntro: String?
    var headerImageUrl: String?
    var isFollowing: Bool?
}

extension User {
    static func transformUser(dict: [String: Any], key: String) -> User {
        let user = User()
        user.id = key
        user.account = dict["account"] as? String
        user.email = dict["email"] as? String
        user.profileImageUrl = dict["profileImageUrl"] as? String
        user.username = dict["username"] as? String
        user.birthday = dict["birthday"] as? String
        user.selfIntro = dict["selfIntro"] as? String
        user.headerImageUrl = dict["headerImageUrl"] as? String
        return user
    }
}
