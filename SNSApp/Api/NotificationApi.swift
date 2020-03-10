//
//  NotificationApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/09.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class NotificationApi {
var REF_NOTIFICATION = Database.database().reference().child("notification")
    
    func observeNotification(withId id: String, completion: @escaping (NotificationModel) -> Void) {
        REF_NOTIFICATION.child(id).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newNoti = NotificationModel.transform(dict: dict, key: snapshot.key)
                completion(newNoti)
            }
        }
    }
}
