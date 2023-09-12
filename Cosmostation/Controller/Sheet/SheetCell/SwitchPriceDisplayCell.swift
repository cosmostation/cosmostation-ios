//
//  SwitchPriceDisplayCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/12.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SwitchPriceDisplayCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var upImg: UIImageView!
    @IBOutlet weak var downImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindPriceDisplay(_ position: Int) {
        if (position == 0) {
            titleLabel.text = "Style 1"
            upImg.image = UIImage.init(named: "iconPriceUpGreen")
            downImg.image = UIImage.init(named: "iconPriceDownRed")
            
        } else {
            titleLabel.text = "Style 2"
            upImg.image = UIImage.init(named: "iconPriceUpRed")
            downImg.image = UIImage.init(named: "iconPriceDownGreen")
            
        }
        
    }
    
}
