//
//  MISettingCell.swift
//  MicroInsight
//
//  Created by 舒雄威 on 2019/5/15.
//  Copyright © 2019 舒雄威. All rights reserved.
//

import UIKit

class MISettingCell: UITableViewCell {

    @IBOutlet weak public var nameLab: UILabel!
    @IBOutlet weak public var rightBtn: UIButton!
    @IBOutlet weak public var rightSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        rightSwitch.isHidden = true
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
