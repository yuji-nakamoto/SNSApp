//
//  SearchViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        fetchUsers()

    }
    
    func fetchUsers() {
        self.users.removeAll()
        UserApi().observeUsers { (user) in
            self.isFollowing(userId: user.id!) { (value) in
                user.isFollowing = value
                self.users.append(user)
                self.tableView.reloadData()
            }
            
        }
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        FollowApi().isFollowing(userId: userId, completed: completed)
    }

}

extension SearchViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell
        let user = users[indexPath.row]
        cell.user = user
        cell.searchVC = self
        return cell
    }
}
