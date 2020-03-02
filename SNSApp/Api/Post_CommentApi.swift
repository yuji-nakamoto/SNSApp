//
//  Post_CommentApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/02.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase

class Post_CommentApi {
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
}
