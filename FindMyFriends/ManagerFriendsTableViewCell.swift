//
//  ManagerFriendsTableViewCell.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/9/1.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ManagerFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var badgeContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        badgeContainerView.layer.cornerRadius = 13
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
