//
//  WalletInjectiveCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/11/18.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class WalletInjectiveCell: UITableViewCell {
    @IBOutlet weak var cardRoot: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
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
    
    var actionDelegate: (() -> Void)? = nil
    var actionVote: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: Any) {
        actionDelegate?()
    }
    @IBAction func onClickVote(_ sender: Any) {
        actionVote?()
    }
    
    override func prepareForReuse() {
        vestingLayer.isHidden = true
    }
    
    func updateView(_ account: Account?, _ chainType: ChainType?) {
        let totalToken = WUtils.getAllMainAsset(INJECTIVE_MAIN_DENOM)
        totalAmount.attributedText = WUtils.displayAmount2(totalToken.stringValue, totalAmount.font!, 18, 6)
        totalValue.attributedText = WUtils.dpUserCurrencyValue(STARGAZE_MAIN_DENOM, totalToken, 18, totalValue.font)
        availableAmount.attributedText = WUtils.displayAmount2(BaseData.instance.getAvailable_gRPC(INJECTIVE_MAIN_DENOM), availableAmount.font!, 18, 6)
        delegatedAmount.attributedText = WUtils.displayAmount2(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, 18, 6)
        unbondingAmount.attributedText = WUtils.displayAmount2(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, 18, 6)
        rewardAmount.attributedText = WUtils.displayAmount2(BaseData.instance.getRewardSum_gRPC(INJECTIVE_MAIN_DENOM), rewardAmount.font, 18, 6)
        
        let vesting = BaseData.instance.getVestingAmount_gRPC(INJECTIVE_MAIN_DENOM)
        if (vesting.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
            vestingAmount.attributedText = WUtils.displayAmount2(BaseData.instance.getVesting_gRPC(INJECTIVE_MAIN_DENOM), vestingAmount.font!, 18, 6)
        }
        BaseData.instance.updateLastTotal(account, totalToken.multiplying(byPowerOf10: -18).stringValue)
    }
    
}
