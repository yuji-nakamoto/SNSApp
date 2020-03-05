//
//  PostViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class PostViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var image: UIImage?
    var pleaceholderLbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextView()
        setupKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupKeyboard() {
        textView.becomeFirstResponder()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func setupView() {
        if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
            profileImage.sd_setImage(with: URL(string: photoUrl.absoluteString), completed: nil)
        }
        profileImage.layer.cornerRadius = 20
        contentImage.layer.cornerRadius = 20
        contentImage.contentMode = .scaleAspectFill
        
        sendButton.layer.cornerRadius = 14
        sendButton.isEnabled = false
        sendButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 0.5)
    }
    
    func setupTextView() {
        textView.delegate = self
        pleaceholderLbl.isHidden = false
        
        let pleaceholderX: CGFloat = self.view.frame.size.width / 40
        let pleaceholderY: CGFloat = 0
        let pleaceholderWidth: CGFloat = textView.bounds.width - pleaceholderX
        let pleaceholderHeight: CGFloat = textView.bounds.height
        let pleaceholderFontSize = self.view.frame.size.width / 25
        
        pleaceholderLbl.frame = CGRect(x: pleaceholderX, y: pleaceholderY, width: pleaceholderWidth, height: pleaceholderHeight)
        pleaceholderLbl.text = "いまどうしてる？"
        pleaceholderLbl.font = UIFont(name: "HelveticaNeue", size: pleaceholderFontSize)
        pleaceholderLbl.textColor = .lightGray
        pleaceholderLbl.textAlignment = .left
        
        textView.addSubview(pleaceholderLbl)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = 0
        } else {
            if #available(iOS 11.0, *) {
                bottomConstraint.constant = -keyboardViewEndFrame.height + view.safeAreaInsets.bottom
            } else {
                bottomConstraint.constant = -keyboardViewEndFrame.height
            }
            view.layoutIfNeeded()
        }
    }
    
    @IBAction func photoSelectedAction(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func cameraSelectedAction(_ sender: Any) {
        
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        ProgressHUD.show()
        
        guard self.image != nil else {
            ProgressHUD.showError("画像を選択してください")
            return
        }
        let photoId = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: "gs://snsapp-bc1d9.appspot.com/").child("posts").child(photoId)
        if let profileImg = self.image, let imageData = profileImg.jpegData(compressionQuality: 0.1) {
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                storageRef.downloadURL { (url, error) in
                    if let imageUrl = url?.absoluteString {
                        self.sendDataToFirebase(imageUrl: imageUrl)
                    } else {
                        ProgressHUD.showError(error?.localizedDescription)
                        return
                    }
                }
            }
        }
        
    }
    
    func sendDataToFirebase(imageUrl: String) {
        let ref = Database.database().reference().child("posts")
        let postId = ref.childByAutoId().key
        let postRef = ref.child(postId!)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        postRef.setValue(["uid": currentUserId, "contentImageUrl": imageUrl, "caption": textView.text!]) { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            let myPostRef = MyPostApi().REF_MYPOSTS.child(currentUserId).child(postId!)
            myPostRef.setValue(true) { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
            }
            ProgressHUD.showSuccess()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[.originalImage] as? UIImage {
            image = imageSelected
            contentImage.image = imageSelected
            sendButton.isEnabled = true
            sendButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1)
            
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PostViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty {
            sendButton.isEnabled = true
            sendButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1)
            pleaceholderLbl.isHidden = true
        } else {
            sendButton.isEnabled = false
            sendButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 0.5)
            pleaceholderLbl.isHidden = false
        }
    }
}
