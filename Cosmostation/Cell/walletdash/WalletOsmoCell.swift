//
//  WalletOsmoCell.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/06/22.
//  Copyright © 2021 wannabit. All rights reserved.
//

import UIKit

class WalletOsmoCell: UITableViewCell {
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
    @IBOutlet weak var btnDefi: UIButton!
    @IBOutlet weak var btnWalletConnect: UIButton!

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
    var actionLab: (() -> Void)? = nil
    var actionWc: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: Any) {
        actionDelegate?()
    }
    @IBAction func onClickVote(_ sender: Any) {
        actionVote?()
    }
    @IBAction func onClickLab(_ sender: Any) {
        actionLab?()
    }
    @IBAction func onClickWc(_ sender: Any) {
        actionWc?()
    }
    
    override func prepareForReuse() {
        vestingLayer.isHidden = true
    }
    
    func updateView(_ account: Account?, _ chainType: ChainType?) {
        let totalToken = WUtils.getAllMainAsset(OSMOSIS_MAIN_DENOM)
        totalAmount.attributedText = WDP.dpAmount(totalToken.stringValue, totalAmount.font!, 6, 6)
        totalValue.attributedText = WUtils.dpValueUserCurrency(OSMOSIS_MAIN_DENOM, totalToken, 6, totalValue.font)
        availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(OSMOSIS_MAIN_DENOM), availableAmount.font!, 6, 6)
        delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, 6, 6)
        unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, 6, 6)
        rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(OSMOSIS_MAIN_DENOM), rewardAmount.font, 6, 6)
        BaseData.instance.updateLastTotal(account, totalToken.multiplying(byPowerOf10: -6).stringValue)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDelegate.borderColor = UIColor.init(named: "_font05")
        btnProposal.borderColor = UIColor.init(named: "_font05")
        btnDefi.borderColor = UIColor.init(named: "_font05")
        btnWalletConnect.borderColor = UIColor.init(named: "_font05")
    }
    
}
