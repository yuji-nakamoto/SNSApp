//
//  OtherFollowerViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/16.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase

class OtherFollowerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    var delegate: ProfileViewDelegate?
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        loadFollowers()
    }
    
    func loadFollowers() {
        FollowApi().observeFollowers(withUser: userId) { (user) in
            guard let userId = user.uid else {
                return
            }
            self.fetchUser(uid: userId) {
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        UserApi().observeFollowUser(withId: uid) { (user) in
            self.isFollowing(userId: user.id!) { (value) in
                user.isFollowing = value
                self.users.append(user)
                completed()
            }
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        FollowApi().isFollowing(userId: userId, completed: completed)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OtherVC"{
            let otherVC = segue.destination as! OtherProfileViewController
            let userId = sender as! String
            otherVC.userId = userId
            otherVC.delegate = self
        }
    }
    
}

extension OtherFollowerViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowerCell", for: indexPath) as! FollowerTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        cell.otherFollowerVC = self
        cell.delegate = self.delegate
        
        return cell
    }
}

extension OtherFollowerViewController: ProfileViewDelegate {
    func updateFollowButton(forUser user: User) {
        for u in self.users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}

