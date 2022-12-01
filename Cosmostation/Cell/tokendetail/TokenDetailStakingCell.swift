//
//  TokenDetailStakingCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/08/19.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class TokenDetailStakingCell: UITableViewCell {
    @IBOutlet weak var cardRoot: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var delegatedAmount: UILabel!
    @IBOutlet weak var unbondingAmount: UILabel!
    @IBOutlet weak var rewardAmount: UILabel!
    @IBOutlet weak var vestingAmount: UILabel!
    @IBOutlet weak var vestingLayer: UIView!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var vestingLabel: UILabel!
    @IBOutlet weak var delegateLabel: UILabel!
    @IBOutlet weak var unbondingLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        delegatedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        rewardAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unbondingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        totalLabel.text = NSLocalizedString("str_total", comment: "")
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        vestingLabel.text = NSLocalizedString("str_vesting", comment: "")
        delegateLabel.text = NSLocalizedString("str_delegated", comment: "")
        unbondingLabel.text = NSLocalizedString("str_unbonding", comment: "")
        rewardLabel.text = NSLocalizedString("str_reward", comment: "")
    }
    
    override func prepareForReuse() {
        vestingLayer.isHidden = true
    }
    
    func onBindStakingToken(_ chainConfig: ChainConfig) {
        let stakingDenom = chainConfig.stakeDenom
        let totalToken = WUtils.getAllMainAsset(stakingDenom)
        totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
        availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(stakingDenom), availableAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
        delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
        unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, chainConfig.divideDecimal, chainConfig.displayDecimal)
        rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(stakingDenom), rewardAmount.font, chainConfig.divideDecimal, chainConfig.displayDecimal)
        
        let vesting = BaseData.instance.getVestingAmount_gRPC(stakingDenom)
        if (vesting.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
            vestingAmount.attributedText = WDP.dpAmount(BaseData.instance.getVesting_gRPC(stakingDenom), availableAmount.font!, chainConfig.divideDecimal, chainConfig.displayDecimal)
        }
        cardRoot.backgroundColor = chainConfig.chainColorBG
    }
    
}
