    //
    //  InboxViewController.swift
    //  SNSApp
    //
    //  Created by yuji_nakamoto on 2020/03/11.
    //  Copyright © 2020 yuji_nakamoto. All rights reserved.
    //
    
    import UIKit
    import Firebase
    import SideMenu
    
    class InboxViewController: UIViewController {
        
        @IBOutlet weak var profileImage: UIImageView!
        @IBOutlet weak var tableView: UITableView!
        var inboxArray = [Inbox]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            setupAvatar()
            observeInbox()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.navigationController?.navigationBar.isHidden = false
        }
        
        func observeInbox() {
            InboxApi().observeLastMessages(uid: Auth.auth().currentUser!.uid) { (inbox) in
                if !self.inboxArray.contains(where: { $0.user.uid == inbox.user.uid }) {
                    self.inboxArray.append(inbox)
                    self.sortMessage()
                }
            }
        }
        
        func sortMessage() {
            inboxArray = inboxArray.sorted(by: { $0.date > $1.date })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        func setupAvatar() {
            profileImage.layer.cornerRadius = 35/2
            if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
                profileImage.sd_setImage(with: URL(string: photoUrl.absoluteString), completed: nil)
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
            return inboxArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InboxCell", for: indexPath) as! InboxTableViewCell
            let inbox = inboxArray[indexPath.row]
            cell.inbox = inbox
            cell.inboxVC = self
            return cell
        }
        
    }
