//
//  MyValidatorCell.swift
//  Cosmostation
//
//  Created by yongjoo on 22/03/2019.
//  Copyright © 2019 wannabit. All rights reserved.
//

import UIKit

class MyValidatorCell: UITableViewCell {
    
    @IBOutlet weak var myDelegateTitleLabel: UILabel!
    @IBOutlet weak var myUnbondingTitleLabel: UILabel!
    @IBOutlet weak var myRewardTitleLabel: UILabel!
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var validatorImg: UIImageView!
    @IBOutlet weak var revokedImg: UIImageView!
    @IBOutlet weak var monikerLabel: UILabel!
    @IBOutlet weak var bandOracleOffImg: UIImageView!
    @IBOutlet weak var myDelegatedAmoutLabel: UILabel!
    @IBOutlet weak var myUndelegatingAmountLabel: UILabel!
    @IBOutlet weak var rewardAmoutLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        validatorImg.layer.borderWidth = 1
        validatorImg.layer.masksToBounds = false
        validatorImg.layer.borderColor = UIColor.font04.cgColor
        validatorImg.layer.cornerRadius = validatorImg.frame.height/2
        validatorImg.clipsToBounds = true
        
        self.selectionStyle = .none
        
        myDelegatedAmoutLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        myUndelegatingAmountLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        rewardAmoutLabel.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: Font_12_caption1)
        myDelegateTitleLabel.text = NSLocalizedString("str_my_delegation", comment: "")
        myUnbondingTitleLabel.text = NSLocalizedString("str_my_unbonding", comment: "")
        myRewardTitleLabel.text = NSLocalizedString("str_my_reward", comment: "")
    }
    
    override func prepareForReuse() {
        self.validatorImg.image = UIImage(named: "validatorDefault")
        self.myDelegatedAmoutLabel.text = "-"
        self.myUndelegatingAmountLabel.text = "-"
        self.rewardAmoutLabel.text = "-"
        self.bandOracleOffImg.isHidden = true
        super.prepareForReuse()
    }
    
    func updateView(_ validator: Cosmos_Staking_V1beta1_Validator, _ chainConfig: ChainConfig?) {
        if (chainConfig == nil) { return }
        let chainType = chainConfig!.chainType
        monikerLabel.text = validator.description_p.moniker
        monikerLabel.adjustsFontSizeToFitWidth = true
        if (validator.jailed == true) {
            revokedImg.isHidden = false
            validatorImg.layer.borderColor = UIColor.warnRed.cgColor
        } else {
            revokedImg.isHidden = true
            validatorImg.layer.borderColor = UIColor.font04.cgColor
        }
        
        myDelegatedAmoutLabel.attributedText = WDP.dpAmount(BaseData.instance.getDelegated_gRPC(validator.operatorAddress).stringValue, myDelegatedAmoutLabel.font, chainConfig!.divideDecimal, 6)
        myUndelegatingAmountLabel.attributedText = WDP.dpAmount(BaseData.instance.getUnbonding_gRPC(validator.operatorAddress).stringValue, myUndelegatingAmountLabel.font, chainConfig!.divideDecimal, 6)
        rewardAmoutLabel.attributedText = WDP.dpAmount(BaseData.instance.getReward_gRPC(WUtils.getMainDenom(chainConfig), validator.operatorAddress).stringValue, rewardAmoutLabel.font, chainConfig!.divideDecimal, 6)
        
        cardView.backgroundColor = chainConfig?.chainColorBG
        if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operatorAddress)) {
            validatorImg.af_setImage(withURL: url)
        }
        
        //display for band oracle status
        if (chainType == .BAND_MAIN) {
            if (BaseData.instance.mParam?.params?.band_active_validators?.addresses.contains(validator.operatorAddress) == false) {
                bandOracleOffImg.isHidden = false
            }
        }
            
    }
    
    func updateAuthzView(_ validator: Cosmos_Staking_V1beta1_Validator, _ chainConfig: ChainConfig?,
                         _ granterDelegation: Array<Cosmos_Staking_V1beta1_DelegationResponse>, _ granterUnbonding: Array<Cosmos_Staking_V1beta1_UnbondingDelegation>,
                         _ granterReward: Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>) {
        if (chainConfig == nil) { return }
        let chainType = chainConfig!.chainType
        monikerLabel.text = validator.description_p.moniker
        monikerLabel.adjustsFontSizeToFitWidth = true
        if (validator.jailed == true) {
            revokedImg.isHidden = false
            validatorImg.layer.borderColor = UIColor.warnRed.cgColor
        } else {
            revokedImg.isHidden = true
            validatorImg.layer.borderColor = UIColor.font04.cgColor
        }
        
        //DP granter delegation amount
        var delegatedAmount = NSDecimalNumber.zero
        if let matchedDelegate = granterDelegation.filter({ $0.delegation.validatorAddress == validator.operatorAddress }).first {
            delegatedAmount = NSDecimalNumber.init(string: matchedDelegate.balance.amount)
        }
        myDelegatedAmoutLabel.attributedText = WDP.dpAmount(delegatedAmount.stringValue, myDelegatedAmoutLabel.font, chainConfig!.divideDecimal, 6)
        
        //DP granter unbonding amount
        var unbondingAmount = NSDecimalNumber.zero
        if let matchedUnbonding = granterUnbonding.filter({ $0.validatorAddress == validator.operatorAddress }).first {
            matchedUnbonding.entries.forEach { entry in
                unbondingAmount = unbondingAmount.adding(NSDecimalNumber.init(string: entry.balance))
            }
        }
        myUndelegatingAmountLabel.attributedText = WDP.dpAmount(unbondingAmount.stringValue, myUndelegatingAmountLabel.font, chainConfig!.divideDecimal, 6)
        
        //DP granter staking reward amount
        var rewardAmount = NSDecimalNumber.zero
        if let matchedReward = granterReward.filter({ $0.validatorAddress == validator.operatorAddress }).first {
            matchedReward.reward.forEach({ reward in
                if (reward.denom == chainConfig?.stakeDenom) {
                    rewardAmount = rewardAmount.adding(NSDecimalNumber.init(string: reward.amount))
                }
            })
        }
        rewardAmount = rewardAmount.multiplying(byPowerOf10: -18)
        rewardAmoutLabel.attributedText = WDP.dpAmount(rewardAmount.stringValue, rewardAmoutLabel.font, chainConfig!.divideDecimal, 6)
        
        cardView.backgroundColor = chainConfig?.chainColorBG
        if let url = URL(string: WUtils.getMonikerImgUrl(chainConfig, validator.operatorAddress)) {
            validatorImg.af_setImage(withURL: url)
        }
        
        //display for band oracle status
        if (chainType == .BAND_MAIN) {
            if (BaseData.instance.mParam?.params?.band_active_validators?.addresses.contains(validator.operatorAddress) == false) {
                bandOracleOffImg.isHidden = false
            }
        }
        
    }
    
}
