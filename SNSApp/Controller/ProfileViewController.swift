//
//  ProfileViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/04.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import AVFoundation

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    var users = [User]()
    var user: User!
    var player = AVAudioPlayer()
    let refresh = UIRefreshControl()
    let soundFilePath = Bundle.main.path(forResource: "refresh", ofType: "mp3")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        setupSound()
        fetchUser()
        loadMyPosts()
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUser()
    }
    
    
    @objc func update(){
        player.play()
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    func fetchUser() {
        UserApi().observeCurrentUser { (user) in
            MyPostApi().fetchCountMyPosts(userId: user.id) { (count) in
                self.navigationItem.title = "\(user.username)のツイート \(count)"
                self.user = user
                self.tableView.reloadData()
            }
        }
    }
    
    func loadMyPosts() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        self.posts.removeAll()
        MyPostApi().fetchMyPosts(userId: currentUser.uid) { (key) in
            PostApi().observePost(withId: key) { (post) in
                self.fetchPostUser(uid: post.uid!) {
                    self.posts.insert(post, at: 0)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func fetchPostUser(uid: String, completed: @escaping () -> Void) {
        UserApi().observeUser(withId: uid) { (user) in
            self.users.insert(user, at: 0)
            completed()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentVC"{
            let commentVC = segue.destination as! CommentViewController
            let postId = sender as? String
            commentVC.postId = postId!
        }
    }
    
    func setupSound() {
        do {
            try player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundFilePath!))
            player.prepareToPlay()
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension ProfileViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  indexNumber = indexPath.row
        
        if indexNumber == 0 {
            let cell_1 = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
            if let user = self.user {
                cell_1.user = user
                cell_1.profileVC = self
            }
            return cell_1
        }
        let cell_2 = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row - 1]
        let user = users[indexPath.row - 1]
        cell_2.user = user
        cell_2.post = post
        cell_2.profileVC = self
        
        return cell_2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let  indexNumber = indexPath.row
        
        if indexNumber == 0 {
            return UITableView.automaticDimension
        }
        let post = posts[indexPath.row - 1]
            var height_1: CGFloat = 0
            var height_2: CGFloat = 0
            let heightPost = post.height
            let widthPost = post.width
            let caption = post.caption

            if !post.caption!.isEmpty && post.imageUrl == nil {
                height_1 = caption!.estimateFrameForText_2(caption!).height + 110
                return height_1
            }
            if !post.caption!.isEmpty && heightPost != 0, widthPost != 0 {
                height_2 = caption!.estimateFrameForText_2(caption!).height + 300
                return height_1 + height_2
            }
            if  post.caption!.isEmpty && heightPost != 0, widthPost != 0 {
                height_1 = CGFloat(heightPost! / widthPost! * 500)
            }
            return height_1
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let  indexNumber = indexPath.row
        
        if indexNumber == 0 {
        }
        if editingStyle == .delete {
            let post = posts[indexPath.row - 1]
            PostApi().REF_POSTS.child(post.id!).removeValue()
            posts.remove(at: indexPath.row - 1)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }
}
