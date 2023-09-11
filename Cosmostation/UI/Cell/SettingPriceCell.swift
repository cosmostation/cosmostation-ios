//
//  SettingPriceCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SettingPriceCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var setImg: UIImageView!
    @IBOutlet weak var setTitleLabel: UILabel!
    @IBOutlet weak var setMsgLabel: UILabel!
    @IBOutlet weak var upImg: UIImageView!
    @IBOutlet weak var downImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setMsgLabel.isHidden = true
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
    }
    
    func onBindSetDpPrice() {
        setImg.image = UIImage(named: "setPriceColor")
        setTitleLabel.text = NSLocalizedString("setting_price_color_title", comment: "")
        
        if (BaseData.instance.getPriceChaingColor() > 0) {
            upImg.image = UIImage.init(named: "iconPriceUpRed")
            downImg.image = UIImage.init(named: "iconPriceDownGreen")
        } else {
            upImg.image = UIImage.init(named: "iconPriceUpGreen")
            downImg.image = UIImage.init(named: "iconPriceDownRed")
        }
        
    }
    
}
