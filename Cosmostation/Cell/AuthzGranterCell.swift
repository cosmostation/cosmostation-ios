//
//  AuthzGranterCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/26.
//  Copyright © 2022 wannabit. All rights reserved.
//

import UIKit

class AuthzGranterCell: UITableViewCell {

    @IBOutlet weak var granterAddressLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var availableAmountLabel: UILabel!
    @IBOutlet weak var vestingAmountLabel: UILabel!
    @IBOutlet weak var delegatedAmountLabel: UILabel!
    @IBOutlet weak var unbondingAmountLabel: UILabel!
    @IBOutlet weak var stakingRewardAmountLabel: UILabel!
    @IBOutlet weak var commissionAmountLabel: UILabel!
    
    @IBOutlet weak var vestingLayer: UIView!
    @IBOutlet weak var commissionLayer: UIView!
    
    var actionGranterAddress: (() -> Void)? = nil
    
    @IBAction func onClickGranterAddress(_ sender: UIButton) {
        actionGranterAddress?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        delegatedAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unbondingAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        stakingRewardAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        commissionAmountLabel.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    func onBindView(_ chainConfig: ChainConfig?, _ address: String,
                    _ available: Coin?, _ vesting: Coin?, _ delegated: Coin?, _ unbonding: Coin?,
                    _ reward: Coin?, _ commission: Coin?) {
        if (chainConfig == nil) { return }
        let stakingDenom = chainConfig!.stakeDenom
        guard let msAsset = BaseData.instance.getMSAsset(chainConfig!, stakingDenom) else {
            return
        }
        
        let availableAmount = WUtils.plainStringToDecimal(available?.amount)
        let vestingAmount = WUtils.plainStringToDecimal(vesting?.amount)
        let delegatedAmount = WUtils.plainStringToDecimal(delegated?.amount)
        let unbondingAmount = WUtils.plainStringToDecimal(unbonding?.amount)
        let rewardAmount = WUtils.plainStringToDecimal(reward?.amount)
        let commissionAmount = WUtils.plainStringToDecimal(commission?.amount)
        let totalAmount = availableAmount.adding(delegatedAmount).adding(vestingAmount).adding(unbondingAmount).adding(rewardAmount).adding(commissionAmount)
        
        granterAddressLabel.text = address
        granterAddressLabel.adjustsFontSizeToFitWidth = true
        
        availableAmountLabel.attributedText = WDP.dpAmount(availableAmount.stringValue, availableAmountLabel.font!, chainConfig!.divideDecimal, 6)
        vestingAmountLabel.attributedText = WDP.dpAmount(vestingAmount.stringValue, availableAmountLabel.font!, chainConfig!.divideDecimal, 6)
        delegatedAmountLabel.attributedText = WDP.dpAmount(delegatedAmount.stringValue, availableAmountLabel.font!, chainConfig!.divideDecimal, 6)
        unbondingAmountLabel.attributedText = WDP.dpAmount(unbondingAmount.stringValue, availableAmountLabel.font!, chainConfig!.divideDecimal, 6)
        stakingRewardAmountLabel.attributedText = WDP.dpAmount(rewardAmount.stringValue, availableAmountLabel.font!, chainConfig!.divideDecimal, 6)
        commissionAmountLabel.attributedText = WDP.dpAmount(totalAmount.stringValue, availableAmountLabel.font!, chainConfig!.divideDecimal, 6)
        if (vestingAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
        }
        if (commissionAmount.compare(NSDecimalNumber.zero).rawValue > 0) {
            commissionLayer.isHidden = false
        }
        
        totalAmountLabel.attributedText = WDP.dpAmount(totalAmount.stringValue, totalAmountLabel.font!, chainConfig!.divideDecimal, 6)
        totalValueLabel.attributedText = WUtils.dpAssetValue(msAsset.coinGeckoId, totalAmount, chainConfig!.divideDecimal, totalValueLabel.font)
        
    }
}
