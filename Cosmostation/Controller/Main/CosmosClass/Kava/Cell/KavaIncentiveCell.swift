//
//  KavaIncentiveCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class KavaIncentiveCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    
    @IBOutlet weak var kavaLayer: UIView!
    @IBOutlet weak var kavaAmountLabel: UILabel!
    @IBOutlet weak var kavaDenomLabel: UILabel!
    @IBOutlet weak var hardLayer: UIView!
    @IBOutlet weak var hardAmountLabel: UILabel!
    @IBOutlet weak var hardDenomLabel: UILabel!
    @IBOutlet weak var usdxLayer: UIView!
    @IBOutlet weak var usdxAmountLabel: UILabel!
    @IBOutlet weak var usdxDenomLabel: UILabel!
    @IBOutlet weak var swpLayer: UIView!
    @IBOutlet weak var swpAmountLabel: UILabel!
    @IBOutlet weak var swpDenomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func onBindIncentive(_ baseChain: BaseChain, _ incentive: Kava_Incentive_V1beta1_QueryRewardsResponse?) {
        let allIncentives = incentive?.allIncentiveCoins()
        if let kavaIncentive = allIncentives?.filter({ $0.denom == KAVA_MAIN_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, kavaIncentive.denom) {
                WDP.dpCoin(msAsset, kavaIncentive, nil, kavaDenomLabel, kavaAmountLabel, msAsset.decimals!)
                kavaLayer.isHidden = false
            }
        }
        
        if let hardIncentive = allIncentives?.filter({ $0.denom == KAVA_HARD_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, hardIncentive.denom) {
                WDP.dpCoin(msAsset, hardIncentive, nil, hardDenomLabel, hardAmountLabel, msAsset.decimals!)
                hardLayer.isHidden = false
            }
        }
        
        if let usdxIncentive = allIncentives?.filter({ $0.denom == KAVA_USDX_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, usdxIncentive.denom) {
                WDP.dpCoin(msAsset, usdxIncentive, nil, usdxDenomLabel, usdxAmountLabel, msAsset.decimals!)
                usdxLayer.isHidden = false
            }
        }
        
        if let swpIncentive = allIncentives?.filter({ $0.denom == KAVA_SWAP_DENOM }).first {
            if let msAsset = BaseData.instance.getAsset(baseChain.apiName, swpIncentive.denom) {
                WDP.dpCoin(msAsset, swpIncentive, nil, swpDenomLabel, swpAmountLabel, msAsset.decimals!)
                swpLayer.isHidden = false
            }
        }
    }
}


extension Kava_Incentive_V1beta1_QueryRewardsResponse {
    
    func allIncentiveCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        
        usdxMintingClaims.forEach { claim in
            if (claim.baseClaim.hasReward) {
                let reward = claim.baseClaim.reward
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Cosmos_Base_V1beta1_Coin.with {$0.denom = reward.denom; $0.amount = sumReward.stringValue }
                    } else {
                        result.append(reward)
                    }
                }
            }
        }
        
        hardLiquidityProviderClaims.forEach { hardIncen in
            hardIncen.baseClaim.reward.forEach { reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Cosmos_Base_V1beta1_Coin.with {$0.denom = reward.denom; $0.amount = sumReward.stringValue }
                    } else {
                        result.append(reward)
                    }
                }
            }
        }
        
        delegatorClaims.forEach { claim in
            claim.baseClaim.reward.forEach({ reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Cosmos_Base_V1beta1_Coin.with {$0.denom = reward.denom; $0.amount = sumReward.stringValue }
                    } else {
                        result.append(reward)
                    }
                }
            })
        }
        
        swapClaims.forEach { claim in
            claim.baseClaim.reward.forEach({ reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Cosmos_Base_V1beta1_Coin.with {$0.denom = reward.denom; $0.amount = sumReward.stringValue }
                    } else {
                        result.append(reward)
                    }
                }
            })
        }
        
        earnClaims.forEach { claim in
            claim.baseClaim.reward.forEach({ reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Cosmos_Base_V1beta1_Coin.with {$0.denom = reward.denom; $0.amount = sumReward.stringValue }
                    } else {
                        result.append(reward)
                    }
                }
            })
        }
        return result
    }
    
    
    func hasUsdxMinting() -> Bool {
        if (usdxMintingClaims.count > 0 && usdxMintingClaims[0].hasBaseClaim &&
            usdxMintingClaims[0].baseClaim.hasReward && usdxMintingClaims[0].baseClaim.reward.amount != "0") {
            return true
        }
        return false
    }
    
    func getHardRewardDenoms() -> Array<String> {
        var result = Array<String>()
        hardLiquidityProviderClaims.forEach { hardClaim in
            hardClaim.baseClaim.reward.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
    
    public func getDelegatorRewardDenoms() -> Array<String> {
        var result = Array<String>()
        delegatorClaims.forEach { delegatorClaim in
            delegatorClaim.baseClaim.reward.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
    
    public func getSwapRewardDenoms() -> Array<String> {
        var result = Array<String>()
        swapClaims.forEach { swapClaim in
            swapClaim.baseClaim.reward.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
    
    public func getEarnRewardDenoms() -> Array<String> {
        var result = Array<String>()
        earnClaims.forEach { swapClaim in
            swapClaim.baseClaim.reward.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
}
