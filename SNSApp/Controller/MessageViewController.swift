//
//  MessageViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/11.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class MessageViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var partnerImage: UIImageView!
    @IBOutlet weak var accountLabel: UILabel!
    
    var messages = [Message]()
    var partnerId: String!
    var messageId: String!
    var user: User!
    var image: UIImage!
    var currentUserId = Auth.auth().currentUser!.uid
    var isTyping = false
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        setupNavigationBarUser()
        setupTextField()
        setupKeyboard()
        handleTextField()
        loadMessage()
        observeActivity()
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
    
    func loadMessage() {
        MessageApi().observeMessage(from: currentUserId, to: partnerId) { (message) in
            self.messages.append(message)
            self.sortMessage()
        }
        MessageApi().observeMessage(from: partnerId, to: currentUserId) { (message) in
            self.fetchUsers(uid: self.partnerId) {
                self.messages.append(message)
                self.sortMessage()
            }
        }
    }
    
    func sortMessage() {
        messages = messages.sorted(by: { $0.date! < $1.date! })
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom() {
        if messages.count > 0 {
            let index = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    
    func fetchUsers(uid: String, completed: @escaping () -> Void) {
        UserApi().observeUser(withId: uid) { (user) in
            self.user = user
            completed()
        }
    }
    
    func setupKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = 0
        } else {
            if #available(iOS 11.0, *) {
                bottomConstraint.constant = view.safeAreaInsets.bottom - keyboardViewEndFrame.height
            } else {
                bottomConstraint.constant = keyboardViewEndFrame.height
            }
            view.layoutIfNeeded()
        }
    }
    
    func setupTextField() {
        messageTextField.layer.cornerRadius = 13
        messageTextField.layer.borderColor = UIColor.lightGray.cgColor
        messageTextField.layer.borderWidth = 1
        messageTextField.borderStyle = .none
        messageTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width:10, height: messageTextField.frame.size.height))
        messageTextField.leftViewMode = UITextField.ViewMode.always
        messageTextField.backgroundColor = UIColor.white
    }
    
    func setupNavigationBarUser() {
        usernameLabel.text = ""
        //        accountLabel.text = ""
        partnerImage.layer.cornerRadius = 18
        UserApi().observeUser(withId: partnerId) { (user) in
            self.usernameLabel.text = user.username
            self.accountLabel.text = user.account
            if let photoUrlString = user.profileImageUrl {
                self.partnerImage.sd_setImage(with: URL(string: photoUrlString), completed: nil)
            }
        }
    }
    
    func handleTextField() {
        messageTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let messageText = messageTextField.text, !messageText.isEmpty {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        
        if !isTyping {
            UserApi().typing(from: currentUserId, to: partnerId)
            isTyping = true
        } else {
            timer.invalidate()
        }
        timerTyping()
    }
    
    func timerTyping() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (t) in
            UserApi().typing(from: self.currentUserId, to: "")
            self.isTyping = false
        })
    }
    
    func observeActivity() {
        let ref = UserApi().REF_USERS.child(partnerId).child("isOnline")
        ref.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "typing" {
                    let typing = snap as! String
                    self.isTyping = typing == self.currentUserId ? true : false
                }
                self.updateTopLabel(bool: self.isTyping)
            }
        }
    }
    
    func updateTopLabel(bool: Bool) {
        if bool {
            if isTyping == true {
                UserApi().observeUser(withId: partnerId) { (user) in
                    self.accountLabel.text = "\(user.account!)さんが入力中です..."
                }
            }
        } else {
            UserApi().observeUser(withId: partnerId) { (user) in
                self.accountLabel.text = user.account
            }
        }
    }
    
    
    @IBAction func dismissActon(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func pickerAction(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if let messageText = messageTextField.text, messageText != "" {
            messageTextField.text = ""
            messageTextField.resignFirstResponder()
            sendButton.isEnabled = false
            sendToFirebase(dict: ["messageText": messageText as Any])
        }
    }
    
    func sendToFirebase(dict: [String: Any]) {
        let date: Double = Date().timeIntervalSince1970
        var value = dict
        value["from"] = currentUserId
        value["to"] = partnerId
        value["date"] = date
        value["read"] = false
        
        MessageApi().sendMessage(from: currentUserId, to: partnerId, value: value)
    }
    
}

extension MessageViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        cell.timeLabel.isHidden = indexPath.row % 3 == 0 ? true : false
        let message = messages[indexPath.row]
        cell.user = self.user
        cell.message = message
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.messageText
        if !text!.isEmpty {
            height = text!.estimateFrameForText_1(text!).height + 60
        }
        
        let heightMessage = message.height
        let widthMessage = message.width
        if heightMessage != 0, widthMessage != 0 {
            height = CGFloat(heightMessage! / widthMessage! * 250)
        }
        return height
    }
}

extension MessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[.originalImage] as? UIImage {
            image = imageSelected
            sendButton.isEnabled = false
            SendDataApi().savePhotoMessage(image: image, onSuccess: { (anyValue) in
                if let dict = anyValue as? [String: Any] {
                    self.sendToFirebase(dict: dict)
                }
            }) { (error) in
                ProgressHUD.showError(error)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
