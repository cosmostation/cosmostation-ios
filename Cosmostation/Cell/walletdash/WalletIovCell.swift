//
//  WalletIovCell.swift
//  Cosmostation
//
//  Created by yongjoo on 28/10/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class WalletIovCell: UITableViewCell {
    
    @IBOutlet weak var rootCardView: CardView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var delegatedAmount: UILabel!
    @IBOutlet weak var unbondingAmount: UILabel!
    @IBOutlet weak var rewardAmount: UILabel!
    @IBOutlet weak var btnDelegate: UIButton!
    @IBOutlet weak var btnProposal: UIButton!
    @IBOutlet weak var btnStarname: UIButton!
    
    @IBOutlet weak var availableLabel: UILabel!
    @IBOutlet weak var delegateLabel: UILabel!
    @IBOutlet weak var unbondingLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        delegatedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unbondingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        rewardAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        
        availableLabel.text = NSLocalizedString("str_available", comment: "")
        delegateLabel.text = NSLocalizedString("str_delegated", comment: "")
        unbondingLabel.text = NSLocalizedString("str_unbonding", comment: "")
        rewardLabel.text = NSLocalizedString("str_reward", comment: "")
        btnDelegate.setTitle(NSLocalizedString("btn_delegate", comment: ""), for: .normal)
        btnProposal.setTitle(NSLocalizedString("btn_governance", comment: ""), for: .normal)
        btnStarname.setTitle(NSLocalizedString("btn_nameservice", comment: ""), for: .normal)
    }
    
    var actionDelegate: (() -> Void)? = nil
    var actionVote: (() -> Void)? = nil
    var actionNameService: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: UIButton) {
        actionDelegate?()
    }
    @IBAction func onClickVote(_ sender: UIButton) {
        actionVote?()
    }
    @IBAction func onClickNameService(_ sender: UIButton) {
        actionNameService?()
    }
    
    func updateView(_ account: Account?, _ chainConfig: ChainConfig?) {
        guard let account = account, let chainConfig = chainConfig else { return }
        let stakingDenom = chainConfig.stakeDenom
        
        let totalToken = WUtils.getAllMainAsset(stakingDenom)
        totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, 6, 6)
        availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(stakingDenom), availableAmount.font!, 6, 6)
        delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, 6, 6)
        unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, 6, 6)
        rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(stakingDenom), rewardAmount.font, 6, 6)
        BaseData.instance.updateLastTotal(account, totalToken.multiplying(byPowerOf10: -6).stringValue)
        
        if let msAsset = BaseData.instance.getMSAsset(chainConfig, stakingDenom) {
            WDP.dpAssetValue(msAsset.coinGeckoId, totalToken, 6, totalValue)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDelegate.borderColor = UIColor.font05
        btnProposal.borderColor = UIColor.font05
        btnStarname.borderColor = UIColor.font05
    }
}
