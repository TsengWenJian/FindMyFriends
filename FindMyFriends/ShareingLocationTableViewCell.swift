//
//  ShareingLocationTableViewCell.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/25.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ShareingLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var shareingSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
