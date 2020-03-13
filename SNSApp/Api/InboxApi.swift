//
//  InboxApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/13.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class InboxApi {
var REF_INBOX = Database.database().reference().child("inbox")
    
    func observeLastMessages(uid: String, comletion: @escaping (Inbox) -> Void) {
        REF_INBOX.child(uid).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                UserApi().getUserInfo(uid: snapshot.key) { (user) in
                    if let inbox = Inbox.transformInbox(dict: dict, user: user) {
                        comletion(inbox)
                    }
                }
            }
        }
    }
    
}
