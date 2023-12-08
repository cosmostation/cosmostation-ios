//
//  ClaimAllChainCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/06.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import Lottie

class ClaimAllChainCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var logoImg1: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var denomLabel: UILabel!
    @IBOutlet weak var valueCurrencyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var stateImg: UIImageView!
    @IBOutlet weak var pendingView: LottieAnimationView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        
    }
    
    func onBindRewards(_ chain: CosmosClass, _ rewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]) {
        logoImg1.image =  UIImage.init(named: chain.logo1)
        nameLabel.text = chain.name.uppercased()
        
        var mainRewardDenom = ""
        var mainRewardAmount = NSDecimalNumber.zero
        if (chain is ChainDydx) {
            mainRewardDenom = DYDX_USDC_DENOM
        } else {
            mainRewardDenom = chain.stakeDenom
        }
        
        rewards.forEach { reward in
            if let rewardCoin = reward.reward.filter({ $0.denom == mainRewardDenom }).first {
                let amount = NSDecimalNumber(string: rewardCoin.amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                mainRewardAmount = mainRewardAmount.adding(amount)
            }
        }
        
        let mainRewardCoin = Cosmos_Base_V1beta1_Coin(mainRewardDenom, mainRewardAmount.stringValue)
        if let msAsset = BaseData.instance.getAsset(chain.apiName, mainRewardDenom) {
            WDP.dpCoin(msAsset, mainRewardCoin, nil, denomLabel, amountLabel, msAsset.decimals)
        }
        
        var rewardsValue = NSDecimalNumber.zero
        rewards.forEach { reward in
            reward.reward.forEach { deCoin in
                if let msAsset = BaseData.instance.getAsset(chain.apiName, deCoin.denom) {
                    let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, false)
                    let amount = NSDecimalNumber(string: deCoin.amount) .multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                    let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                    rewardsValue = rewardsValue.adding(value)
                }
            }
        }
        WDP.dpValue(rewardsValue, valueCurrencyLabel, valueLabel)
        
    }
    
}
