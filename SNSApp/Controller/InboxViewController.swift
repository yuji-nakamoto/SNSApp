    //
    //  InboxViewController.swift
    //  SNSApp
    //
    //  Created by yuji_nakamoto on 2020/03/11.
    //  Copyright © 2020 yuji_nakamoto. All rights reserved.
    //
    
    import UIKit
    import SideMenu
    
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
                let partnerId = sender as? String
                messageVC.partnerId = partnerId!
            }
        }
        @IBAction func toSideMenuVC(_ sender: Any) {
            let menu = SideMenuManager.default.leftMenuNavigationController!
            present(menu, animated: true, completion: nil)
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
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if let cell = tableView.cellForRow(at: indexPath) as? InboxTableViewCell {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageVC") as! MessageViewController
                messageVC.imagePartner = cell.profileImage.image
                messageVC.partnerUsername = cell.usernameLabel.text!
                messageVC.partnerId = cell.user!.uid!
                messageVC.partnerUser = cell.user
                self.navigationController?.pushViewController(messageVC, animated: true)
            }
        }
    }
