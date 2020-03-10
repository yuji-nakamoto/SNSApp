//
//  Notification.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/09.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
class NotificationModel {
    var from: String?
    var objectId: String?
    var timestamp: Int?
    var id: String?
    var type: String?
}

extension NotificationModel {
 
    static func transform(dict: [String: Any], key: String) -> NotificationModel {
        let notification = NotificationModel()
        notification.id = key
        notification.objectId = dict["objectId"] as? String
        notification.timestamp = dict["timestamp"] as? Int
        notification.from = dict["from"] as? String
        notification.type = dict["type"] as? String
        
        return notification
    }
}
