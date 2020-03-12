//
//  MessageApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/12.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class MessageApi {
    var REF_MESSAGE = Database.database().reference().child("messages")
    
    func observeMessage(from: String, to: String, completion: @escaping (Message) -> Void) {
        REF_MESSAGE.child(from).child(to).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newMessage = Message.transformMessage(dict: dict)
                completion(newMessage)
            }
        }
    }

}
