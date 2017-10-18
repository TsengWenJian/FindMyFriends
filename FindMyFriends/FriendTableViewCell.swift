//
//  FriendTableViewCell.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/8/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var subDetailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        photoImageView.layer.cornerRadius = 24

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
        
    }

}
