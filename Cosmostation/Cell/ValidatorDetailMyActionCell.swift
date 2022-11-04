//
//  ValidatorDetailMyActionCell.swift
//  Cosmostation
//
//  Created by yongjoo on 04/04/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class ValidatorDetailMyActionCell: UITableViewCell {

    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var myDelegateAmount: UILabel!
    @IBOutlet weak var myUndelegateAmount: UILabel!
    @IBOutlet weak var myRewardAmount: UILabel!
    @IBOutlet weak var myDailyReturns: UILabel!
    @IBOutlet weak var myMonthlyReturns: UILabel!
    
    @IBOutlet weak var delegateBtn: UIButton!
    @IBOutlet weak var undelegateBtn: UIButton!
    @IBOutlet weak var redelegateBtn: UIButton!
    @IBOutlet weak var claimRewardBtn: UIButton!
    @IBOutlet weak var reInvestBtn: UIButton!
    
    @IBOutlet weak var myDelegatedTitle: UILabel!
    @IBOutlet weak var myUnbondingTitle: UILabel!
    @IBOutlet weak var myRewardTitle: UILabel!
    @IBOutlet weak var estDailyRewardTitle: UILabel!
    @IBOutlet weak var estMonthlyRewardTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        myDelegateAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myUndelegateAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myRewardAmount.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myDailyReturns.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myMonthlyReturns.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: Font_13_footnote)
        myDelegatedTitle.text = NSLocalizedString("str_my_delegation", comment: "")
        myUnbondingTitle.text = NSLocalizedString("str_my_unbonding", comment: "")
        myRewardTitle.text = NSLocalizedString("str_my_reward", comment: "")
        estDailyRewardTitle.text = NSLocalizedString("str_est_daily_reward", comment: "")
        estMonthlyRewardTitle.text = NSLocalizedString("str_est_monthly_reward", comment: "")
        
        delegateBtn.setTitle(NSLocalizedString("str_delegate", comment: ""), for: .normal)
        undelegateBtn.setTitle(NSLocalizedString("str_undelegate", comment: ""), for: .normal)
        redelegateBtn.setTitle(NSLocalizedString("str_redelegate", comment: ""), for: .normal)
        claimRewardBtn.setTitle(NSLocalizedString("str_claim_reward", comment: ""), for: .normal)
        reInvestBtn.setTitle(NSLocalizedString("str_compounding", comment: ""), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var actionDelegate: (() -> Void)? = nil
    var actionUndelegate: (() -> Void)? = nil
    var actionRedelegate: (() -> Void)? = nil
    var actionReward: (() -> Void)? = nil
    var actionReinvest: (() -> Void)? = nil
    
    @IBAction func onClickDelegate(_ sender: Any) {
        actionDelegate?()
    }
    @IBAction func onClickUndelegate(_ sender: Any) {
        actionUndelegate?()
    }
    @IBAction func onClickRedelegate(_ sender: Any) {
        actionRedelegate?()
    }
    @IBAction func onClickReward(_ sender: Any) {
        actionReward?()
    }
    @IBAction func onClickReInvest(_ sender: Any) {
        actionReinvest?()
    }
    
    func updateView(_ validator: Cosmos_Staking_V1beta1_Validator?, _ chainConfig: ChainConfig?) {
        if (chainConfig == nil) { return }
        let chainType = chainConfig!.chainType
        cardView.backgroundColor = chainConfig?.chainColorBG
        let delegation = BaseData.instance.getDelegated_gRPC(validator!.operatorAddress)
        let unbonding = BaseData.instance.getUnbonding_gRPC(validator!.operatorAddress)
        let reward = BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), validator!.operatorAddress)
        myDelegateAmount.attributedText =  WDP.dpAmount(delegation.stringValue, myDelegateAmount.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        myUndelegateAmount.attributedText =  WDP.dpAmount(unbonding.stringValue, myUndelegateAmount.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        myRewardAmount.attributedText = WDP.dpAmount(reward.stringValue, myRewardAmount.font, chainConfig!.divideDecimal, chainConfig!.displayDecimal)
        
        if (validator?.status == Cosmos_Staking_V1beta1_BondStatus.bonded) {
            myDailyReturns.attributedText =  WUtils.getDailyReward(myDailyReturns.font, NSDecimalNumber.init(string: validator?.commission.commissionRates.rate).multiplying(byPowerOf10: -18), delegation, chainConfig!)
            myMonthlyReturns.attributedText =  WUtils.getMonthlyReward(myMonthlyReturns.font, NSDecimalNumber.init(string: validator?.commission.commissionRates.rate).multiplying(byPowerOf10: -18), delegation, chainConfig!)
            
        } else {
            myDailyReturns.attributedText =  WUtils.getDailyReward(myDailyReturns.font, NSDecimalNumber.zero, NSDecimalNumber.zero, chainConfig!)
            myMonthlyReturns.attributedText =  WUtils.getMonthlyReward(myMonthlyReturns.font, NSDecimalNumber.zero, NSDecimalNumber.zero, chainConfig!)
            myDailyReturns.textColor = UIColor.init(hexString: "f31963")
            myMonthlyReturns.textColor = UIColor.init(hexString: "f31963")
            
        }
        //temp hide apr for no mint param chain
        if (chainType == .ALTHEA_TEST) {
            myDailyReturns.text = "--"
            myMonthlyReturns.text = "--"
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        delegateBtn.borderColor = UIColor.font05
        undelegateBtn.borderColor = UIColor.font05
        redelegateBtn.borderColor = UIColor.font05
        claimRewardBtn.borderColor = UIColor.font05
        reInvestBtn.borderColor = UIColor.font05
    }
}
