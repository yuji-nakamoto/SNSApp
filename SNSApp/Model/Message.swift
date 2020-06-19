//
//  Message.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/12.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation

class Message {
    var messageText: String
    var imageUrl: String
    var to: String
    var from: String
    var date: Double
    var height: Double
    var width: Double
    
    init(messageText: String, imageUrl: String, to: String, from: String, date: Double, height: Double, width: Double) {
        self.messageText = messageText
        self.imageUrl = imageUrl
        self.to = to
        self.from = from
        self.date = date
        self.height = height
        self.width = width
    }
    
    static func transformMessage(dict: [String: Any]) -> Message? {
        guard let from = dict["from"] as? String,
            let to = dict["to"] as? String,
            let date = dict["date"] as? Double else {
                return nil
        }
        
        let messageText = (dict["messageText"] as? String) == nil ? "" : (dict["messageText"]! as! String)
        let imageUrl = (dict["imageUrl"] as? String) == nil ? "" : (dict["imageUrl"]! as! String)
        let width = (dict["width"] as? Double) == nil ? 0 : (dict["width"]! as! Double)
        let height = (dict["height"] as? Double) == nil ? 0 : (dict["height"]! as! Double)
        
        let message = Message(messageText: messageText, imageUrl: imageUrl, to: to, from: from, date: date, height: height, width: width)
        return message
    }
}
