//
//  EarnStatusCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/10/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class EarnStatusCell: UITableViewCell {
    
    @IBOutlet weak var liquidityTitleLabel: UILabel!
    @IBOutlet weak var liquidityAmountLabel: UILabel!
    @IBOutlet weak var liquidityDenomLabel: UILabel!
    @IBOutlet weak var availableTitleLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var availableDenomLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        liquidityAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        availableAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
    }
    
    
    func onBindView(_ deposits: Array<Coin>) {
        var sum = NSDecimalNumber.zero
        deposits.forEach { coin in
            sum = sum.adding(NSDecimalNumber.init(string: coin.amount))
        }
        liquidityAmountLabel.attributedText = WDP.dpAmount(sum.stringValue, liquidityAmountLabel.font!, 6, 6)
        availableAmountLabel.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(KAVA_MAIN_DENOM), availableAmountLabel.font!, 6, 6)
    }
}
