//
//  TokenDetailCustomCell.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/04/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class TokenDetailCustomCell: UITableViewCell {
    @IBOutlet weak var cardRoot: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var bondedAmount: UILabel!
        
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var bondedLabel: UILabel!

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var coinDataLayout: UIStackView!
    @IBOutlet weak var coinDataConstraint: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        bondedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        totalLabel.text = NSLocalizedString("str_total", comment: "")
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        bondedLabel.text = NSLocalizedString("str_vault_bonded", comment: "")
    }
    
    func onBindStakingToken(_ chainConfig: ChainConfig) {
        let stakingDenom = chainConfig.stakeDenom
        
        if (chainConfig.chainType == .NOBLE_MAIN) {
            let totalToken = BaseData.instance.getAvailableAmount_gRPC(stakingDenom)
            totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
            
            view.isHidden = true
            coinDataLayout.isHidden = true
            coinDataConstraint?.isActive = false
            
        } else {
            let bonded = NSDecimalNumber.zero
            let totalToken = BaseData.instance.getAvailableAmount_gRPC(stakingDenom).adding(bonded)
            
            totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
            availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(stakingDenom), availableAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
            bondedAmount.attributedText = WDP.dpAmount(bonded.stringValue, bondedAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
            
            view.isHidden = false
            coinDataLayout.isHidden = false
            coinDataConstraint?.isActive = true
        }
        cardRoot.backgroundColor = chainConfig.chainColorBG
    }
}
