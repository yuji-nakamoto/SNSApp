//
//  SendDataApi.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/08.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import Foundation
import Firebase
import ProgressHUD

class SendDataApi {
    func uploadImageToFirebaseStorage(data: Data, caption: String, onSuccess: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: "gs://snsapp-bc1d9.appspot.com/").child("posts").child(photoIdString)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                if let photoUrl = url?.absoluteString{
                    
                    self.sendDataToDatabase(photoUrl: photoUrl, caption: caption, onSuccess: {
                        onSuccess(photoUrl)
                    })
                }
            })
        }
    }
    
     func savePhotoMessage(image: UIImage? ,onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        if let imagePhoto = image {
            let photoIdString = NSUUID().uuidString
            let storageRef = Storage.storage().reference(forURL: "gs://snsapp-bc1d9.appspot.com/").child("messages").child(photoIdString)
            if let data = imagePhoto.jpegData(compressionQuality: 0.1) {
                storageRef.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil {
                        onError(error!.localizedDescription)
                    }
                    storageRef.downloadURL { (url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            let dict: Dictionary<String, Any> = [
                                "imageUrl": metaImageUrl as Any,
                                "height": imagePhoto.size.height as Any,
                                "width": image?.size.width as Any,
                                "messageText": "" as Any
                            ]
                            onSuccess(dict)
                        }
                    }
                }
            }
        }
    }
    
    func sendDataToDatabase(photoUrl: String, caption: String, onSuccess: @escaping () -> Void) {
        let newPostId = PostApi().REF_POSTS.childByAutoId().key
        let newPostReference = PostApi().REF_POSTS.child(newPostId!)
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        
        newPostReference.setValue(["uid": currentUserId,"photoImageUrl": photoUrl, "caption": caption, "likeCount": 0, "timestamp": timestamp]) { (error, ref) in
            if error != nil{
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            
            FeedApi().REF_FEED.child(Auth.auth().currentUser!.uid).child(newPostId!).setValue(true)
            
            FollowApi().REF_FOLLOWERS.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
                let arraySnapshot = snapshot.children.allObjects as! [DataSnapshot]
                arraySnapshot.forEach { (child) in
                    FeedApi().REF_FEED.child(child.key).updateChildValues(["\(newPostId!)": true])
                    let newNotiId = NotificationApi().REF_NOTIFICATION.child(child.key).childByAutoId().key
                    let newNotiReference = NotificationApi().REF_NOTIFICATION.child(child.key).child(newNotiId!)
                    newNotiReference.setValue(["from": Auth.auth().currentUser!.uid, "objectId": newPostId!,"type": "feed", "timestamp": timestamp])
                }
            }
            
            let myPostRef = MyPostApi().REF_MYPOSTS.child(currentUserId).child(newPostId!)
            myPostRef.setValue(true) { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
            }
            ProgressHUD.showSuccess()
            onSuccess()
        }
    }
}
