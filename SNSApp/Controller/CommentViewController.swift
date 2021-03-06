//
//  CommentViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/01.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class CommentViewController: UIViewController,UITextFieldDelegate {
    
    var postId = ""
    var comments = [Comment]()
    var users = [User]()
    var post = Post()
    var user: User!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = .secondarySystemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        setupKeyboard()
        setupTextField()
        handleTextField()
        setupSendBtn()
        loadComments()
        loadPost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func loadComments() {
        Post_CommentApi().REF_POST_COMMENTS.child(self.postId).observe(.childAdded) { (snapshot) in
            CommentApi().observeComments(withPostId: snapshot.key) { (comment) in
                self.fetchUsers(uid: comment.uid!) {
                    self.comments.append(comment)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchUsers(uid: String, completed: @escaping () -> Void) {
        UserApi().observeUser(withId: uid) { (user) in
            self.users.append(user)
            completed()
        }
    }
    
    func loadPost() {
        PostApi().observePost(withId: postId) { (post) in
            guard let postUid = post.uid else {
                return
            }
            self.fetchPostUser(uid: postUid, completed: {
                self.post = post
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchPostUser(uid:String, completed: @escaping () -> Void) {
        UserApi().observeUser(withId: uid, comletion: {
            user in
            self.user = user
            completed()
        })
    }
    
    func setupTextField() {
        textField.layer.cornerRadius = 13
        textField.layer.borderColor = UIColor.systemGray.cgColor
        textField.layer.borderWidth = 1
        textField.borderStyle = .none
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width:10, height: textField.frame.size.height))
        textField.leftViewMode = UITextField.ViewMode.always
        textField.backgroundColor = UIColor(named: "Dark Color")
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
    
    func handleTextField() {
        textField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        if let commentText = textField.text, !commentText.isEmpty {
            sendButton.isEnabled = true
            sendButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 1)
            return
        }
        setupSendBtn()
    }
    
    @IBAction func sendBtnDidTapped(_ sender: Any) {
        let ref = Database.database().reference().child("comments")
        let commentId = ref.childByAutoId().key
        let commnetRef = ref.child(commentId!)
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        let currentUserId = currentUser.uid
        commnetRef.setValue(["uid": currentUserId, "commentText": textField.text!]) { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            let postCommentRef = Database.database().reference().child("post-comments").child(self.postId).child(commentId!)
            postCommentRef.setValue(true) { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
            }
            self.textField.text = ""
            self.textField.resignFirstResponder()
            self.setupSendBtn()
        }
    }
    
    func setupSendBtn() {
        sendButton.layer.cornerRadius = 13
        self.sendButton.isEnabled = false
        self.sendButton.backgroundColor = UIColor(red: 59/255, green: 150/255, blue: 255/255, alpha: 0.5)
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OtherVC"{
            let otherVC = segue.destination as! OtherProfileViewController
            let userId = sender as? String
            otherVC.userId = userId!
        }
    }
    
}

extension CommentViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  indexNumber = indexPath.row
        
        if indexNumber == 0 {
            let cell_1 = tableView.dequeueReusableCell(withIdentifier: "ContributorCell", for: indexPath) as! ContributorTableViewCell
            cell_1.user = user
            cell_1.post = post
            cell_1.commentVC = self
            return cell_1
        }
        let cell_2 = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        let comment = comments[indexPath.row - 1]
        let user = users[indexPath.row - 1]
        cell_2.user = user
        cell_2.comment = comment
        cell_2.commentVC = self
        
        return cell_2
    }
}
