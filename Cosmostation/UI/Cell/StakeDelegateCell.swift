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
    @IBOutlet weak var inactiveTag: UIImageView!
    @IBOutlet weak var jailedTag: UIImageView!
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
    @IBOutlet weak var estTitleLabel: UILabel!
    @IBOutlet weak var estLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        rootView.setBlur()
        logoImg.af.cancelImageRequest()
        logoImg.image = UIImage(named: "validatorDefault")
        jailedTag.isHidden = true
        inactiveTag.isHidden = true
    }
    //YONG4
    func onBindMyDelegate(_ baseChain: BaseChain, _ validator: Cosmos_Staking_V1beta1_Validator, _ delegation: Cosmos_Staking_V1beta1_DelegationResponse) {
        
//        logoImg.af.setImage(withURL: baseChain.monikerImg(validator.operatorAddress))
//        nameLabel.text = validator.description_p.moniker
//        if (validator.jailed) {
//            jailedTag.isHidden = false
//        } else {
//            inactiveTag.isHidden = validator.status == .bonded
//        }
//        
//        let stakeDenom = baseChain.stakeDenom!
//        if let msAsset = BaseData.instance.getAsset(baseChain.apiName, stakeDenom) {
//            
//            let vpAmount = NSDecimalNumber(string: validator.tokens).multiplying(byPowerOf10: -msAsset.decimals!)
//            vpLabel?.attributedText = WDP.dpAmount(vpAmount.stringValue, vpLabel!.font, 0)
//            
//            let commission = NSDecimalNumber(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -16)
//            commLabel?.attributedText = WDP.dpAmount(commission.stringValue, commLabel!.font, 2)
//            
//            let stakedAmount = NSDecimalNumber(string: delegation.balance.amount).multiplying(byPowerOf10: -msAsset.decimals!)
//            stakingLabel?.attributedText = WDP.dpAmount(stakedAmount.stringValue, stakingLabel!.font, msAsset.decimals!)
//            
//            if let rewards = baseChain.cosmosRewards?.filter({ $0.validatorAddress == validator.operatorAddress }).first?.reward {
//                if let mainDenomReward = rewards.filter({ $0.denom == stakeDenom }).first {
//                    let mainDenomrewardAmount = NSDecimalNumber(string: mainDenomReward.amount).multiplying(byPowerOf10: -18).multiplying(byPowerOf10: -msAsset.decimals!)
//                    rewardLabel?.attributedText = WDP.dpAmount(mainDenomrewardAmount.stringValue, rewardLabel!.font, msAsset.decimals!)
//                    
//                } else {
//                    rewardLabel?.attributedText = WDP.dpAmount("0", rewardLabel!.font, msAsset.decimals!)
//                    rewardTitle.text = "Reward"
//                    estLabel?.attributedText = WDP.dpAmount("0", estLabel!.font, msAsset.decimals!)
//                    return
//                }
//                
//                var anotherCnt = 0
//                rewards.filter({ $0.denom != stakeDenom }).forEach { anotherRewards in
//                    let anotherAmount = NSDecimalNumber(string: anotherRewards.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
//                    if (anotherAmount != NSDecimalNumber.zero) {
//                        anotherCnt = anotherCnt + 1
//                    }
//                }
//                if (anotherCnt > 0) {
//                    rewardTitle.text = "Reward + " + String(anotherCnt)
//                } else {
//                    rewardTitle.text = "Reward"
//                }
//                
//            } else {
//                rewardLabel?.attributedText = WDP.dpAmount("0", rewardLabel!.font, msAsset.decimals!)
//                rewardTitle.text = "Reward"
//            }
//            
//            //Display monthly est reward amount
//            let apr = NSDecimalNumber(string: baseChain.getChainParam()["params"]["apr"].string ?? "0")
//            let staked = NSDecimalNumber(string: delegation.balance.amount)
//            let comm = NSDecimalNumber.one.subtracting(NSDecimalNumber(string: validator.commission.commissionRates.rate).multiplying(byPowerOf10: -18))
//            let est = staked.multiplying(by: apr).multiplying(by: comm, withBehavior: handler0).dividing(by: NSDecimalNumber.init(string: "12"), withBehavior: handler0).multiplying(byPowerOf10: -msAsset.decimals!)
//            estLabel?.attributedText = WDP.dpAmount(est.stringValue, estLabel!.font, msAsset.decimals!)
//        }
        
    }
    
}


