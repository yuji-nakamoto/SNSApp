//
//  SideMenuTableViewCell.swift
//  SNSApp
//
//  Created by yuji_nakamoto on 2020/03/03.
//  Copyright © 2020 yuji_nakamoto. All rights reserved.
//

import UIKit
import SideMenu
import Firebase
import ProgressHUD

class SideMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var toSettingLabel: UILabel!
    @IBOutlet weak var toProfileLabel: UILabel!
    
    var sideMenuVC: SideMenuViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureForProfileIcon = UITapGestureRecognizer(target: self, action: #selector(self.toProfileVC))
        profileIcon.addGestureRecognizer(tapGestureForProfileIcon)
        let tapGestureForProfileLbl = UITapGestureRecognizer(target: self, action: #selector(self.toProfileVC))
        toProfileLabel.addGestureRecognizer(tapGestureForProfileLbl)
  
    }
    
    @objc func toProfileVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
        sideMenuVC?.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
