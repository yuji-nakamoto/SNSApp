//
//  SearchViewController.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/07.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import SideMenu

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchBar = UISearchBar()
    var users = [User]()
    var delegate: ProfileViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "ユーザー名を検索"
        searchBar.frame.size.width = view.frame.size.width - 60
        
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchItem
        doSearch()
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        FollowApi().isFollowing(userId: userId, completed: completed)
    }
    
    func doSearch() {
        if let searchText = searchBar.text?.lowercased() {
            self.users.removeAll()
            self.tableView.reloadData()
            UserApi().queryUsers(withText: searchText) { (user) in
                self.isFollowing(userId: user.id!) { (value) in
                    user.isFollowing = value
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func doAccountSearch() {
        if let searchText = searchBar.text?.lowercased() {
            self.users.removeAll()
            self.tableView.reloadData()
            UserApi().queryAccounts(withText: searchText) { (user) in
                self.isFollowing(userId: user.id!) { (value) in
                    user.isFollowing = value
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OtherVC"{
            let otherVC = segue.destination as! OtherProfileViewController
            let userId = sender as! String
            otherVC.userId = userId
            otherVC.delegate = self
        }
    }
    
    @IBAction func toSideMenuVC(_ sender: Any) {
        let menu = SideMenuManager.default.leftMenuNavigationController!
        present(menu, animated: true, completion: nil)
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
        cell.delegate = self.delegate
        return cell
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.hasPrefix("@") == true {
            doAccountSearch()
        } else {
            doSearch()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.hasPrefix("@") == true {
            doAccountSearch()
        } else {
            doSearch()
        }
    }
}

extension SearchViewController: ProfileViewDelegate {
    func updateFollowButton(forUser user: User) {
        for u in self.users {
            if u.id == user.id {
                u.isFollowing = user.isFollowing
                self.tableView.reloadData()
            }
        }
    }
}
