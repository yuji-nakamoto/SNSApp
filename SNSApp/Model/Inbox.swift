//
//  Inbox.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/13.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation

class Inbox {
    var date: Double
    var messageText: String
    var user: User
    var read = false
    
    init(date: Double, messageText: String, user: User, read: Bool) {
        self.date = date
        self.messageText = messageText
        self.user = user
        self.read = read
    }
    
    static func transformInbox(dict: [String: Any], user: User) -> Inbox? {
        guard let date = dict["date"] as? Double,
            let messageText = dict["messageText"] as? String,
            let read = dict["read"] as? Bool else {
                return nil
        }
        
        let inbox = Inbox(date: date, messageText: messageText, user: user, read: read)
        return inbox
    }
    
    func updateData(key: String, value: Any) {
        switch key {
        case "messageText": self.messageText = value as! String
        case "date": self.date = value as! Double
        default: break
        }
    }
}
