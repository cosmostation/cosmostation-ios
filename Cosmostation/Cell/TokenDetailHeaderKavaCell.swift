//
//  TokenDetailHeaderKavaCell.swift
//  Cosmostation
//
//  Created by yongjoo on 11/11/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class TokenDetailKavaCell: TokenDetailCell {
    
    @IBOutlet weak var cardRoot: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var delegatedAmount: UILabel!
    @IBOutlet weak var unbondingAmount: UILabel!
    @IBOutlet weak var rewardAmount: UILabel!
    @IBOutlet weak var vestingAmount: UILabel!
    @IBOutlet weak var havestDepositedAmount: UILabel!
    @IBOutlet weak var unClaimedIncentiveAmount: UILabel!
    @IBOutlet weak var vestingLayer: UIView!
    @IBOutlet weak var havestDepositLayer: UIView!
    @IBOutlet weak var unClaimedIncentiveLayer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        delegatedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unbondingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        rewardAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        vestingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        havestDepositedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unClaimedIncentiveAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        vestingLayer.isHidden = true
        havestDepositLayer.isHidden = true
        unClaimedIncentiveLayer.isHidden = true
    }
    
    func onBindTokens(_ account: Account) {
        let balances = BaseData.instance.mBalances
        let bondingList = BaseData.instance.mBondingList
        let unbondingList = BaseData.instance.mUnbondingList
        let rewardList = BaseData.instance.mRewardList
        let allvalidatorList = BaseData.instance.mAllValidator

        let total = WUtils.getAllKava(balances, bondingList, unbondingList, rewardList, allvalidatorList)
        let available = WUtils.availableAmount(balances, KAVA_MAIN_DENOM)
        let delegated = WUtils.deleagtedAmount(bondingList, allvalidatorList)
        let unbonding = WUtils.unbondingAmount(unbondingList)
        let reward = WUtils.rewardAmount(rewardList, KAVA_MAIN_DENOM)
        let vesting = WUtils.lockedAmount(balances, KAVA_MAIN_DENOM)
        
        totalAmount.attributedText = WUtils.displayAmount2(total.stringValue, totalAmount.font, 6, 6)
        totalValue.attributedText = WUtils.dpTokenValue(total, BaseData.instance.getLastPrice(), 6, totalValue.font)
        availableAmount.attributedText = WUtils.displayAmount2(available.stringValue, availableAmount.font, 6, 6)
        delegatedAmount.attributedText = WUtils.displayAmount2(delegated.stringValue, delegatedAmount.font, 6, 6)
        unbondingAmount.attributedText = WUtils.displayAmount2(unbonding.stringValue, unbondingAmount.font, 6, 6)
        rewardAmount.attributedText = WUtils.displayAmount2(reward.stringValue, rewardAmount.font, 6, 6)
        vestingAmount.attributedText = WUtils.displayAmount2(vesting.stringValue, vestingAmount.font, 6, 6)
        if (vesting != NSDecimalNumber.zero) {
            vestingLayer.isHidden = false
        }
    }
}
