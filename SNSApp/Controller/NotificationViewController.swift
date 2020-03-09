//
//  NotificationViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/09.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase

class NotificationViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var notifications = [NotificationModel]()
    var users = [User]()
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        loadNotification()
        setupAvatar()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func loadNotification() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        NotificationApi().observeNotification(withId: currentUser.uid) { (notification) in
            guard let uid = notification.from else {
                return
            }
            self.fetchUser(uid: uid) {
                self.notifications.insert(notification, at: 0)
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        UserApi().observeUser(withId: uid) { (user) in
            self.users.insert(user, at: 0)
            completed()
        }
    }
    
    func setupAvatar() {
        profileImage.layer.cornerRadius = 35/2
        if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
            profileImage.sd_setImage(with: URL(string: photoUrl.absoluteString), completed: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentVC"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as? String
            commentVC.postId = postId!
        }
    }
    
    @IBAction func toProfileVC(_ sender: Any) {
        performSegue(withIdentifier: "ProfileVC", sender: nil)
    }
    

}

extension NotificationViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        let notification = notifications[indexPath.row]
        let user = users[indexPath.row]
        cell.user = user
        cell.notification = notification
        cell.notiVC = self

        return cell
    }
    
}
