//
//  TokenDetailNativeCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TokenDetailNativeCell: UITableViewCell {
    
    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var lockedAmount: UILabel!
    @IBOutlet weak var fronzenAmount: UILabel!
    @IBOutlet weak var vestingAmount: UILabel!
    
    @IBOutlet weak var lockedLayer: UIView!
    @IBOutlet weak var frozenLayer: UIView!
    @IBOutlet weak var vestingLayer: UIView!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var lockedLabel: UILabel!
    @IBOutlet weak var frozenLabel: UILabel!
    @IBOutlet weak var vestingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        lockedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        fronzenAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        totalLabel.text = NSLocalizedString("str_total", comment: "")
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        lockedLabel.text = NSLocalizedString("str_locked", comment: "")
        frozenLabel.text = NSLocalizedString("str_frozen", comment: "")
        vestingLabel.text = NSLocalizedString("str_vesting", comment: "")
    }
    
    override func prepareForReuse() {
        lockedLayer.isHidden = true
        frozenLayer.isHidden = true
        vestingLayer.isHidden = true
    }
    
    func onBindNativeToken(_ chainConfig: ChainConfig?, _ denom: String?) {
        if (chainConfig?.isGrpc == true) {
            onBindNativeToken_gRPC(chainConfig, denom)
        }
    }
    
    func onBindNativeToken_gRPC(_ chainConfig: ChainConfig?, _ denom: String?) {
        if (chainConfig == nil || denom == nil) { return }
        if let msAsset = BaseData.instance.getMSAsset(chainConfig!, denom!) {
            let decimal = msAsset.decimals
            if (chainConfig?.chainType == ChainType.KAVA_MAIN) {
                onBindKavaTokens(denom)
            } else {
                let total = BaseData.instance.getAvailableAmount_gRPC(denom!)
                totalAmount.attributedText = WDP.dpAmount(total.stringValue, totalAmount.font, decimal, decimal)
                availableAmount.attributedText = WDP.dpAmount(total.stringValue, availableAmount.font, decimal, decimal)
            }
        }
    }
    
    func onBindKavaTokens(_ denom: String?) {
        let chainConfig = ChainKava.init(.KAVA_MAIN)
        let dpDecimal = WUtils.getDenomDecimal(chainConfig, denom!)
        let available = BaseData.instance.getAvailableAmount_gRPC(denom!)
        let vesting = BaseData.instance.getVestingAmount_gRPC(denom!)
        
        totalAmount.attributedText = WDP.dpAmount(available.adding(vesting).stringValue, totalAmount.font, dpDecimal, dpDecimal)
        availableAmount.attributedText = WDP.dpAmount(available.stringValue, availableAmount.font, dpDecimal, dpDecimal)
        if (vesting.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
            vestingAmount.attributedText = WDP.dpAmount(vesting.stringValue, vestingAmount.font!, dpDecimal, dpDecimal)
        }
        
        if (denom == KAVA_HARD_DENOM) {
            rootCardView.backgroundColor = UIColor.cardBg
        } else if (denom == KAVA_USDX_DENOM) {
            rootCardView.backgroundColor = UIColor.cardBg
        } else if (denom == KAVA_SWAP_DENOM) {
            rootCardView.backgroundColor = UIColor.cardBg
        }
    }
}
