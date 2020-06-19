//
//  Configs.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/06/19.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation

let serverKey = "AAAAvZHnW0A:APA91bGBKGLuK35NfRnIxnHSVo6z1zZ-rTSB5sid2TNufzjUJjMYs3JJRNuTHK9FOJzEovJQ6vb1j7zfO5hYadOReDPuHSiasuZaG1SmWfUg-l4jYaWDvdG_M_BznY30ICjyEHBxa6FT"
let fcmUrl = "https://fcm.googleapis.com/fcm/send"
func sendRequestNotification(fromUser: User, toUser: User, message: String, badge: Int) {
    var request = URLRequest(url: URL(string: fcmUrl)!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    
    let notification: [String: Any] = [ "to": "/topics/\(String(describing: toUser.uid))",
        "notification": ["title": fromUser.username,
                          "body": message,
                          "sound": "default",
                          "badge": badge,
                          "customData": ["uid": fromUser.uid,
                                         "username": fromUser.username,
                                         "email": fromUser.email,
                                         "profileImageUrl": fromUser.profileImageUrl]
        ]
    ]
    
    let data = try! JSONSerialization.data(withJSONObject: notification, options: [])
    request.httpBody = data
    
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
        guard let data = data, error == nil else {
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            print("HttpUrlResponse \(httpResponse.statusCode)")
            print("Response \(String(describing: response))")
        }
        
        if let responseString = String(data: data, encoding: String.Encoding.utf8) {
            print("ResponseString \(responseString)")
        }
    }.resume()
    
}
