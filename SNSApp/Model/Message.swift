//
//  Message.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/12.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation

class Message {
    var messageText: String?
    var imageUrl: String?
    var to: String?
    var from: String?
    var date: Double?
    var read: Bool?
    var height: Double?
    var width: Double?
}

extension Message {
    static func transformMessage(dict: [String: Any]) -> Message {
        let message = Message()
        message.messageText = dict["messageText"] as? String == nil ? "" : dict["messageText"] as! String
        message.imageUrl = dict["imageUrl"] as? String == nil ? "" : dict["imageUrl"] as! String
        message.to = dict["to"] as? String
        message.from = dict["from"] as? String
        message.date = dict["date"] as? Double
        message.height = dict["height"] as? Double == nil ? 0 : dict["height"] as! Double
        message.width = dict["width"] as? Double == nil ? 0 : dict["width"] as! Double
        message.read = dict["read"] as? Bool

        return message
    }
}
