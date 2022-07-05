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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        delegatedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        rewardAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unbondingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    override func prepareForReuse() {
        vestingLayer.isHidden = true
    }
    
    func onBindStakingToken(_ chainType: ChainType) {
        let chainConfig = ChainFactory.getChainConfig(chainType)
        let stakingDenom = WUtils.getMainDenom(chainConfig)
        let stakingDivideDecimal = WUtils.mainDivideDecimal(chainType)
        let stakingDisplayDecimal = WUtils.mainDisplayDecimal(chainType)
        let totalToken = WUtils.getAllMainAsset(stakingDenom)
        totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, stakingDivideDecimal, stakingDisplayDecimal)
        availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(stakingDenom), availableAmount.font!, stakingDivideDecimal, stakingDisplayDecimal)
        delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, stakingDivideDecimal, stakingDisplayDecimal)
        unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, stakingDivideDecimal, stakingDisplayDecimal)
        rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(stakingDenom), rewardAmount.font, stakingDivideDecimal, stakingDisplayDecimal)
        
        let vesting = BaseData.instance.getVestingAmount_gRPC(stakingDenom)
        if (vesting.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
            vestingAmount.attributedText = WDP.dpAmount(BaseData.instance.getVesting_gRPC(stakingDenom), availableAmount.font!, stakingDivideDecimal, stakingDisplayDecimal)
        }
        cardRoot.backgroundColor = chainConfig?.chainColorBG
    }
    
}
