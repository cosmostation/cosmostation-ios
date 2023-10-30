//
//  BaseImgSheetCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class BaseImgSheetCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindBuyCrypto(_ position: Int) {
        if (position == 0) {
            imgView.image = UIImage(named: "iconBuymoonpay")
            titleLabel.text = "MOONPAY"
            descriptionLabel.text = "Buy Asset with Moonpay"
            descriptionLabel.isHidden = false
            
        } else if (position == 1) {
            imgView.image = UIImage(named: "iconBuyKado")
            titleLabel.text = "KADO"
            descriptionLabel.isHidden = true
            
        } else if (position == 2) {
            imgView.image = UIImage(named: "iconBuyBinance")
            titleLabel.text = "BINANCE"
            descriptionLabel.isHidden = true
            
        }
    }
    
}
