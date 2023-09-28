//
//  StakeDelegateCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import AlamofireImage
import SwiftyJSON

class StakeDelegateCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var jailedImg: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vpTitle: UILabel!
    @IBOutlet weak var vpLabel: UILabel!
    @IBOutlet weak var commTitle: UILabel!
    @IBOutlet weak var commLabel: UILabel!
    @IBOutlet weak var commPercentLabel: UILabel!
    @IBOutlet weak var stakingTitle: UILabel!
    @IBOutlet weak var stakingLabel: UILabel!
    @IBOutlet weak var rewardTitle: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        logoImg.layer.cornerRadius = logoImg.frame.height/2
        logoImg.clipsToBounds = true
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        logoImg.af.cancelImageRequest()
        logoImg.image = UIImage(named: "validatorDefault")
    }
    
    func onBindMyDelegate(_ baseChain: CosmosClass, _ validator: Cosmos_Staking_V1beta1_Validator, _ delegation: Cosmos_Staking_V1beta1_DelegationResponse) {
        
        logoImg.af.setImage(withURL: baseChain.monikerImg(validator.operatorAddress))
        nameLabel.text = validator.description_p.moniker
        jailedImg.isHidden = !validator.jailed
        
        let stakeDenom = baseChain.stakeDenom!
        if let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
            
            let vpAmount = NSDecimalNumber(string: validator.tokens).multiplying(byPowerOf10: -msAsset.decimals!)
            vpLabel?.attributedText = WDP.dpAmount(vpAmount.stringValue, vpLabel!.font, 0)
            
            let commission = NSDecimalNumber(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
            if (commission == NSDecimalNumber.zero) {
                commLabel.textColor = .colorGreen
                commPercentLabel.textColor = .colorGreen
            } else {
                commLabel.textColor = .color02
                commPercentLabel.textColor = .color02
            }
            
            let stakedAmount = NSDecimalNumber(string: delegation.balance.amount).multiplying(byPowerOf10: -msAsset.decimals!)
            stakingLabel?.attributedText = WDP.dpAmount(stakedAmount.stringValue, stakingLabel!.font, msAsset.decimals!)
            
            if let rewards = baseChain.cosmosRewards.filter({ $0.validatorAddress == validator.operatorAddress }).first?.reward,
               let mainDenomReward = rewards.filter({ $0.denom == stakeDenom }).first {
                let mainDenomrewardAmount = NSDecimalNumber(string: mainDenomReward.amount).multiplying(byPowerOf10: -18).multiplying(byPowerOf10: -msAsset.decimals!)
                rewardLabel?.attributedText = WDP.dpAmount(mainDenomrewardAmount.stringValue, rewardLabel!.font, msAsset.decimals!)
                if (rewards.count > 2) {
                    rewardTitle.text = "Reward + " + String(rewards.count - 1)
                } else {
                    rewardTitle.text = "Reward"
                }
                
            } else {
                rewardLabel?.attributedText = WDP.dpAmount("0", rewardLabel!.font, msAsset.decimals!)
                rewardTitle.text = "Reward"
            }
        }
    }
    
}
