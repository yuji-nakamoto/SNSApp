    //
    //  InboxViewController.swift
    //  SNSApp
    //
    //  Created by yuji_nakamoto on 2020/03/11.
    //  Copyright © 2020 yuji_nakamoto. All rights reserved.
    //
    
    import UIKit
    
    class InboxViewController: UIViewController {
        
        @IBOutlet weak var tableVlew: UITableView!
        var users = [User]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableVlew.delegate = self
            tableVlew.dataSource = self
            tableVlew.separatorStyle = .none
            fetchUser()
        }
        
        func fetchUser() {
            users.removeAll()
            UserApi().observeUsers { (user) in
                self.users.append(user)
                self.tableVlew.reloadData()
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "MessageVC"{
                let messageVC = segue.destination as! MessageViewController
                let userId = sender as? String
                messageVC.userId = userId!
            }
        }
        
    }
    
    extension InboxViewController: UITableViewDelegate,UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return users.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxTableViewCell
            let user = users[indexPath.row]
            cell.user = user
            cell.inboxVC = self
            return cell
        }
    }
