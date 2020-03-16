//
//  ActivityItem.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/17.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import UIKit
class ActivityItemSorce:NSObject, UIActivityItemSource {
    var messsage: String!
    var image: UIImage!
    var caption: String!
     
    init(messsage: String, image: UIImage, caption: String) {
        self.messsage = messsage
        self.image = image
        self.caption = caption
    }
     
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return messsage as Any
    }
     
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
         
        switch UIActivity.ActivityType.postToFacebook {
        case .postToFacebook:
            return image
        case .postToTwitter:
            return "Twitter"
        default:
            return messsage
        }
    }
}
