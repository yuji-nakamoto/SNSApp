//
//  HomeViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/02/27.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import SDWebImage
import SideMenu

class HomeViewController: UIViewController {
    
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerUsernameLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var posts = [Post]()
    var users = [User]()
    var username = ""
    var profileImageUrl = ""
    var caption = ""
    var contentImageUrl = ""
    let refresh = UIRefreshControl()
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = false
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
        headerUsernameLbl.text = ""
        accountLabel.text = ""
        setupAvatar()
        setupTableView()
        fetchCurrentUsername()
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        setupAvatar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func update(){
        loadPosts()
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func loadPosts() {
        self.posts.removeAll()
        FeedApi().observeFeed(withId: Auth.auth().currentUser!.uid) { (post) in
            guard let postId = post.uid else {
                return
            }
            self.activityIndicatorView.startAnimating()
            self.fetchUser(uid: postId) {
                self.posts.insert(post, at: 0)
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        }
        
        FeedApi().observeFeedRemove(withId: Auth.auth().currentUser!.uid) { (post) in
            self.posts = self.posts.filter { $0.id != post.id }
            self.users = self.users.filter { $0.id != post.uid }
            self.tableView.reloadData()
        }
    }
    
    func fetchCurrentUsername() {
        UserApi().observeCurrentUser { (user) in
            self.headerUsernameLbl.text = user.username
            self.accountLabel.text = user.account
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
        if segue.identifier == "OtherVC"{
            let otherVC = segue.destination as! OtherProfileViewController
            let userId = sender as? String
            otherVC.userId = userId!
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < -200 {
            topConstraint.constant = -50
        } else {
            topConstraint.constant = 0
        }
    }
    
    @IBAction func toSideMenuVC(_ sender: Any) {
        let menu = SideMenuManager.default.leftMenuNavigationController!
        present(menu, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.user = user
        cell.post = post
        cell.homeVC = self
        return cell
    }
}
