//
//  SwitchCurrencyCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class SwitchCurrencyCell: UITableViewCell {
    
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var currencyImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkedImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func onBindCurrency(_ position: Int) {
        titleLabel.text = Currency.getCurrencys()[position].description
        
        currencyImg.image = UIImage(named: "currency" + Currency.getCurrencys()[position].description)
        if (BaseData.instance.getCurrency() == position) {
            checkedImg.isHidden = false
        } else {
            checkedImg.isHidden = true
        }
    }
    
}
