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
import AVFoundation

class PostViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var image: UIImage?
    var pleaceholderLbl = UILabel()
    var user: User?
    var player = AVAudioPlayer()
    let soundFilePath = Bundle.main.path(forResource: "post", ofType: "mp3")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Dark Color")
        setupView()
        setupTextView()
        setupKeyboard()
        setupSound()
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
    
    func setupSound() {
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundFilePath!))
        } catch  {
            print(error.localizedDescription)
        }
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
        let pleaceholderY: CGFloat = -30
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show()
        
        SendDataApi().savePhotoPost(image: image, caption: textView.text, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String: Any] {
                SendDataApi.sendDataToDatabase(caption: self.textView.text, dict: dict) {
                    self.player.play()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }) { (error) in
            ProgressHUD.showError(error)
        }
        
        if let caption = textView.text, !caption.isEmpty && image == nil {
            SendDataApi.sendDataToDatabase(caption: caption, dict: ["" : ""]) {
                self.player.play()
                self.navigationController?.popViewController(animated: true)            }
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
