//
//  ProfileUserTableViewCell.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/8/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ProfileUserTableViewCell: UITableViewCell {
    @IBOutlet weak var updateBtn: UIButton!

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhotoImageView.layer.cornerRadius = 36
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
