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

    @IBOutlet weak var toSettingLabel: UILabel!
    @IBOutlet weak var toProfileLabel: UILabel!
    
    var sideMenuVC: SideMenuViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
