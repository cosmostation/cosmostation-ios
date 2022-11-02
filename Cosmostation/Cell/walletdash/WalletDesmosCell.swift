//
//  WalletDesmosCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/11/26.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class WalletDesmosCell: UITableViewCell {
    @IBOutlet weak var cardRoot: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var delegatedAmount: UILabel!
    @IBOutlet weak var unbondingAmount: UILabel!
    @IBOutlet weak var rewardAmount: UILabel!
    @IBOutlet weak var vestingAmount: UILabel!
    @IBOutlet weak var vestingLayer: UIView!
    @IBOutlet weak var btnDelegate: UIButton!
    @IBOutlet weak var btnProposal: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    
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
        
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        vestingLabel.text = NSLocalizedString("str_vesting", comment: "")
        delegateLabel.text = NSLocalizedString("str_delegated", comment: "")
        unbondingLabel.text = NSLocalizedString("str_unbonding", comment: "")
        rewardLabel.text = NSLocalizedString("str_reward", comment: "")
        btnDelegate.setTitle(NSLocalizedString("btn_delegate", comment: ""), for: .normal)
        btnProposal.setTitle(NSLocalizedString("btn_governance", comment: ""), for: .normal)
        btnProfile.setTitle(NSLocalizedString("btn_profile", comment: ""), for: .normal)
    }
    
    var actionDelegate: (() -> Void)? = nil
    var actionVote: (() -> Void)? = nil
    var actionProfile: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: Any) {
        actionDelegate?()
    }
    @IBAction func onClickVote(_ sender: Any) {
        actionVote?()
    }
    @IBAction func onClickProfile(_ sender: Any) {
        actionProfile?()
    }
    
    override func prepareForReuse() {
        vestingLayer.isHidden = true
    }
    
    func updateView(_ account: Account?, _ chainConfig: ChainConfig?) {
        if (account == nil || chainConfig == nil) { return }
        let totalToken = WUtils.getAllMainAsset(chainConfig!.stakeDenom)
        totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, 6, 6)
        totalValue.attributedText = WUtils.dpAssetValue(chainConfig!.stakeDenom, totalToken, 6, totalValue.font)
        availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(chainConfig!.stakeDenom), availableAmount.font!, 6, 6)
        delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, 6, 6)
        unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, 6, 6)
        rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(chainConfig!.stakeDenom), rewardAmount.font, 6, 6)
        
        let vesting = BaseData.instance.getVestingAmount_gRPC(chainConfig!.stakeDenom)
        if (vesting.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
            vestingAmount.attributedText = WDP.dpAmount(BaseData.instance.getVesting_gRPC(chainConfig!.stakeDenom), vestingAmount.font!, 6, 6)
        }
        BaseData.instance.updateLastTotal(account, totalToken.multiplying(byPowerOf10: -6).stringValue)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDelegate.borderColor = UIColor.font05
        btnProposal.borderColor = UIColor.font05
        btnProfile.borderColor = UIColor.font05
    }
    
}
