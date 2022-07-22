//
//  WalletIrisCell.swift
//  Cosmostation
//
//  Created by yongjoo on 27/09/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class WalletIrisCell: UITableViewCell {
    
    @IBOutlet weak var denomTitle: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var availableAmount: UILabel!
    @IBOutlet weak var delegatedAmount: UILabel!
    @IBOutlet weak var unbondingAmount: UILabel!
    @IBOutlet weak var rewardAmount: UILabel!
    @IBOutlet weak var btnDelegate: UIButton!
    @IBOutlet weak var btnProposal: UIButton!
    @IBOutlet weak var btnNtf: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        availableAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        delegatedAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        rewardAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        unbondingAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
    }
    
    var actionDelegate: (() -> Void)? = nil
    var actionVote: (() -> Void)? = nil
    var actionNFT: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: Any) {
        actionDelegate?()
    }
    @IBAction func onClickVote(_ sender: Any) {
        actionVote?()
    }
    @IBAction func onClickNFT(_ sender: UIButton) {
        actionNFT?()
    }
    
    func updateView(_ account: Account?, _ chainType: ChainType?) {
        if (chainType == ChainType.IRIS_MAIN) {
            denomTitle.text = "IRIS"
            let totalIris = WUtils.getAllMainAsset(IRIS_MAIN_DENOM)
            totalAmount.attributedText = WDP.dpAmount(totalIris.stringValue, totalAmount.font!, 6, 6)
            totalValue.attributedText = WUtils.dpValueUserCurrency(IRIS_MAIN_DENOM, totalIris, 6, totalValue.font)
            availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(IRIS_MAIN_DENOM), availableAmount.font!, 6, 6)
            delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, 6, 6)
            unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, 6, 6)
            rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(IRIS_MAIN_DENOM), rewardAmount.font, 6, 6)
            BaseData.instance.updateLastTotal(account, totalIris.multiplying(byPowerOf10: -6).stringValue)
            
        } else if (chainType == ChainType.IRIS_TEST) {
            denomTitle.text = "BIF"
            let totalBif = WUtils.getAllMainAsset(IRIS_TEST_DENOM)
            totalAmount.attributedText = WDP.dpAmount(totalBif.stringValue, totalAmount.font!, 6, 6)
            totalValue.attributedText = WUtils.dpValueUserCurrency(IRIS_TEST_DENOM, totalBif, 6, totalValue.font)
            availableAmount.attributedText = WDP.dpAmount(BaseData.instance.getAvailable_gRPC(IRIS_TEST_DENOM), availableAmount.font!, 6, 6)
            delegatedAmount.attributedText = WDP.dpAmount(BaseData.instance.getDelegatedSum_gRPC(), delegatedAmount.font!, 6, 6)
            unbondingAmount.attributedText = WDP.dpAmount(BaseData.instance.getUnbondingSum_gRPC(), unbondingAmount.font, 6, 6)
            rewardAmount.attributedText = WDP.dpAmount(BaseData.instance.getRewardSum_gRPC(IRIS_TEST_DENOM), rewardAmount.font, 6, 6)
            BaseData.instance.updateLastTotal(account, totalBif.multiplying(byPowerOf10: -6).stringValue)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        btnDelegate.borderColor = UIColor.init(named: "_font05")
        btnProposal.borderColor = UIColor.init(named: "_font05")
        btnNtf.borderColor = UIColor.init(named: "_font05")
    }
    
}
