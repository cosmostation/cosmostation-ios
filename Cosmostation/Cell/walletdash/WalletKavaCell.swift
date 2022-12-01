//
//  WalletKavaCell.swift
//  Cosmostation
//
//  Created by yongjoo on 11/11/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class WalletKavaCell: UITableViewCell {
    
    @IBOutlet weak var cardKava: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var delegatedAmount: UILabel!
    @IBOutlet weak var unbondingAmount: UILabel!
    @IBOutlet weak var rewardAmount: UILabel!
    @IBOutlet weak var vestingAmount: UILabel!
    @IBOutlet weak var havestDepositedAmount: UILabel!
    @IBOutlet weak var unclaimedIncentiveAmount: UILabel!
    @IBOutlet weak var vestingLayer: UIView!
    @IBOutlet weak var havestDepositLayer: UIView!
    @IBOutlet weak var unClaimedIncentiveLayer: UIView!
    @IBOutlet weak var btnDelegate: UIButton!
    @IBOutlet weak var btnProposal: UIButton!
    @IBOutlet weak var btnCdp: UIButton!
    @IBOutlet weak var btnWalletConnect: UIButton!
    
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
        havestDepositedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unclaimedIncentiveAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        vestingLabel.text = NSLocalizedString("str_vesting", comment: "")
        delegateLabel.text = NSLocalizedString("str_delegated", comment: "")
        unbondingLabel.text = NSLocalizedString("str_unbonding", comment: "")
        rewardLabel.text = NSLocalizedString("str_reward", comment: "")
        btnDelegate.setTitle(NSLocalizedString("btn_delegate", comment: ""), for: .normal)
        btnProposal.setTitle(NSLocalizedString("btn_governance", comment: ""), for: .normal)
        btnCdp.setTitle(NSLocalizedString("btn_kavadefi", comment: ""), for: .normal)
        btnWalletConnect.setTitle(NSLocalizedString("btn_walletconnect", comment: ""), for: .normal)
    }
    
    var actionDelegate: (() -> Void)? = nil
    var actionVote: (() -> Void)? = nil
    var actionCdp: (() -> Void)? = nil
    var actionWC: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: Any) {
        actionDelegate?()
    }
    @IBAction func onClickVote(_ sender: Any) {
        actionVote?()
    }
    @IBAction func onClickCdp(_ sender: Any) {
        actionCdp?()
    }
    @IBAction func onClickWC(_ sender: Any) {
        actionWC?()
    }
    
    override func prepareForReuse() {
        vestingLayer.isHidden = true
        havestDepositLayer.isHidden = true
        unClaimedIncentiveLayer.isHidden = true
    }
    
    func updateView(_ account: Account?, _ chainConfig: ChainConfig?) {
        if (account == nil || chainConfig == nil) { return }
        let stakingDenom = chainConfig!.stakeDenom
        guard let msAsset = BaseData.instance.getMSAsset(chainConfig!, stakingDenom) else {
            return
        }
        
        let totalToken = WUtils.getAllMainAsset(stakingDenom)
        totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, 6, 6)
        totalValue.attributedText = WUtils.dpAssetValue(msAsset.coinGeckoId, totalToken, 6, totalValue.font)
        availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(stakingDenom), availableAmount.font!, 6, 6)
        delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, 6, 6)
        unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, 6, 6)
        rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(stakingDenom), rewardAmount.font, 6, 6)
        
        let vesting = BaseData.instance.getVestingAmount_gRPC(stakingDenom)
        if (vesting.compare(NSDecimalNumber.zero).rawValue > 0) {
            vestingLayer.isHidden = false
            vestingAmount.attributedText = WDP.dpAmount(BaseData.instance.getVesting_gRPC(stakingDenom), vestingAmount.font!, 6, 6)
        }
        BaseData.instance.updateLastTotal(account, totalToken.multiplying(byPowerOf10: -6).stringValue)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDelegate.borderColor = UIColor.font05
        btnProposal.borderColor = UIColor.font05
        btnCdp.borderColor = UIColor.font05
        btnWalletConnect.borderColor = UIColor.font05
    }
    
}
