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
import AVFoundation

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
    var player = AVAudioPlayer()
    let refresh = UIRefreshControl()
    let soundFilePath = Bundle.main.path(forResource: "refresh", ofType: "mp3")
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
        setupSound()
        fetchCurrentUsername()
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        fetchCurrentUsername()
        setupAvatar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func update(){
        player.play()
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    func setupSound() {
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundFilePath!))
            player.prepareToPlay()
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadPosts() {
        posts.removeAll()
        FeedApi().observeFeed(withId: Auth.auth().currentUser!.uid) { (post) in
            guard let postId = post.uid else {
                return
            }
            self.activityIndicatorView.startAnimating()
            self.fetchUser(uid: postId) {
                self.posts.insert(post, at: 0)
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
                self.scrollToTop()
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
    
    func scrollToTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
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
    
    @IBAction func toEditVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "EditVC") as! EditTableViewController
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    @IBAction func toPostVC(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let postVC = storyboard.instantiateViewController(withIdentifier: "PostVC") as! PostViewController
        self.navigationController?.pushViewController(postVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        var height_1: CGFloat = 0
        var height_2: CGFloat = 0
        let caption = post.caption
        let heightPost = post.height
        let widthPost = post.width

        if !post.caption!.isEmpty && post.imageUrl == nil {
            height_1 = caption!.estimateFrameForText_2(caption!).height + 110
            return height_1
        }
        if !post.caption!.isEmpty && heightPost != 0, widthPost != 0 {
            height_2 = caption!.estimateFrameForText_2(caption!).height + 300
            return height_1 + height_2
        }
        if post.caption!.isEmpty && heightPost != 0, widthPost != 0 {
            height_1 = CGFloat(heightPost! / widthPost! * 500)
        }
        return height_1
    }
}
