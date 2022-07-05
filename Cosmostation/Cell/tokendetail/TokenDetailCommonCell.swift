//
//  TokenDetailCommonCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/30.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class TokenDetailCommonCell: TokenDetailCell {
    
    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var availableAmount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    
    func onBindCw20Token(_ chainType: ChainType?, _ cw20Token: Cw20Token) {
        let decimal = cw20Token.decimal
        let total = cw20Token.getAmount()
        
        totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, decimal, decimal)
        availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, decimal, decimal)
    }
}
