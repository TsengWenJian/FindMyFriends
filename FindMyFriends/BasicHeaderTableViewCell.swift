//
//  BasicHeaderTableViewCell.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/29.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class BasicHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var rightLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
