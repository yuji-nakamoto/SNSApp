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

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var posts = [Post]()
    var users = [User]()
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        setupAvatar()
        loadPosts()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 426
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
    func loadPosts() {
        activityIndicatorView.startAnimating()
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let newPost = Post.transformPost(dict: dict)
                self.posts.insert(newPost, at: 0)
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    func setupAvatar() {
        let containView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        containView.addSubview(avatarImageView)
        
        let leftBarButton = UIBarButtonItem(customView: containView)
        self.navigationItem.leftBarButtonItem = leftBarButton
        
        if let currentUser = Auth.auth().currentUser, let photoUrl = currentUser.photoURL {
            avatarImageView.loadImage(photoUrl.absoluteString)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInVC")
            self.present(signInVC, animated: true, completion: nil)
        } catch  {
            ProgressHUD.showError(error.localizedDescription)
            return
        }
    }

}

extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
        let post = posts[indexPath.row]
        cell.post = post
        return cell
    }
    
}
