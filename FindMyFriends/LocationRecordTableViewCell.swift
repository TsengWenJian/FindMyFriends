//
//  LocationRecordTableViewCell.swift
//  FindMyFriends
//
//  Created by TSENGWENJIAN on 2017/6/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class LocationRecordTableViewCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!


    override func awakeFromNib() {
              super.awakeFromNib()
        // Initialization code
       
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.3
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
