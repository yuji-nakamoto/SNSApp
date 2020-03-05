//
//  MyPostApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/05.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class MyPostApi {
    var REF_MYPOSTS = Database.database().reference().child("myPosts")
}
