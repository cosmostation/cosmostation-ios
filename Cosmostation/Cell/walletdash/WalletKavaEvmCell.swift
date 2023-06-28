//
//  WalletKavaEvmCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/06/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class WalletKavaEvmCell: UITableViewCell {
    
    @IBOutlet weak var cardKava: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    
    @IBOutlet weak var availableLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        availableLabel.text = NSLocalizedString("str_available", comment: "")
    }
    
    func updateView() {
        if let amount = BaseData.instance.mEvmBalance?.amount {
            let msAmount = NSDecimalNumber(string: amount)
            WDP.dpAmount(msAmount.stringValue,  18, 18, totalAmount)
            WDP.dpAmount(msAmount.stringValue,  18, 18, availableAmount)
            WDP.dpAssetValue(KAVA_GECKO_ID, msAmount, 18, totalValue)
        }
    }
    
}
