//
//  KavaIncentiveReward.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/03/04.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation

public struct IncentiveReward {
    var hard_claims: Array<HardClaim> = Array<HardClaim>()
    var usdx_minting_claims: Array<UsdxMintingClaim> = Array<UsdxMintingClaim>()
    var delegator_claims: Array<DelegatorClaim> = Array<DelegatorClaim>()
    var swap_claims: Array<SwapClaim> = Array<SwapClaim>()
    var earn_claims: Array<EarnClaim> = Array<EarnClaim>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawHardClaims = dictionary?["hard_liquidity_provider_claims"] as? Array<NSDictionary>  {
            for rawHardClaim in rawHardClaims {
                self.hard_claims.append(HardClaim(rawHardClaim))
            }
        }
        if let rawUsdxMintingClaims = dictionary?["usdx_minting_claims"] as? Array<NSDictionary>  {
            for rawUsdxMintingClaim in rawUsdxMintingClaims {
                self.usdx_minting_claims.append(UsdxMintingClaim(rawUsdxMintingClaim))
            }
        }
        if let rawDelegatorClaims = dictionary?["delegator_claims"] as? Array<NSDictionary>  {
            for rawDelegatorClaim in rawDelegatorClaims {
                self.delegator_claims.append(DelegatorClaim(rawDelegatorClaim))
            }
        }
        if let rawSwapClaims = dictionary?["swap_claims"] as? Array<NSDictionary>  {
            for rawSwapClaim in rawSwapClaims {
                self.swap_claims.append(SwapClaim(rawSwapClaim))
            }
        }
        if let rawEarnClaims = dictionary?["earn_claims"] as? Array<NSDictionary>  {
            for rawEarnClaim in rawEarnClaims {
                self.earn_claims.append(EarnClaim(rawEarnClaim))
            }
        }
    }
    
    public func getAllIncentives() -> Array<Coin> {
        var result = Array<Coin>()
        hard_claims.forEach { claim in
            claim.base_claim?.reward?.forEach({ reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Coin(reward.denom, sumReward.stringValue)
                    } else {
                        result.append(reward)
                    }
                }
            })
        }
        delegator_claims.forEach { claim in
            claim.base_claim?.reward?.forEach({ reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Coin(reward.denom, sumReward.stringValue)
                    } else {
                        result.append(reward)
                    }
                }
            })
        }
        swap_claims.forEach { claim in
            claim.base_claim?.reward?.forEach({ reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Coin(reward.denom, sumReward.stringValue)
                    } else {
                        result.append(reward)
                    }
                }
            })
        }
        earn_claims.forEach { claim in
            claim.base_claim?.reward?.forEach({ reward in
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Coin(reward.denom, sumReward.stringValue)
                    } else {
                        result.append(reward)
                    }
                }
            })
        }
        usdx_minting_claims.forEach { claim in
            if let reward = claim.base_claim?.reward {
                let amount = NSDecimalNumber.init(string: reward.amount)
                if (amount.compare(NSDecimalNumber.zero).rawValue > 0) {
                    if let already = result.firstIndex(where: { $0.denom == reward.denom }) {
                        let sumReward = NSDecimalNumber.init(string: result[already].amount).adding(amount)
                        result[already] = Coin(reward.denom, sumReward.stringValue)
                    } else {
                        result.append(reward)
                    }
                }
            }
        }
        return result;
    }
    
    public func getIncentiveAmount(_ denom: String) -> NSDecimalNumber {
        if let coin = getAllIncentives().filter({ $0.denom == denom }).first {
            return NSDecimalNumber.init(string: coin.amount)
        }
        return NSDecimalNumber.zero
    }
    
    public func getMintingRewardAmount() -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        usdx_minting_claims.forEach { usdxMintingClaim in
            result = result.adding(NSDecimalNumber.init(string: usdxMintingClaim.base_claim?.reward?.amount))
        }
        return result
    }
    
    public func getHardRewardDenoms() -> Array<String> {
        var result = Array<String>()
        hard_claims.forEach { hardClaim in
            hardClaim.base_claim?.reward?.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
    
    public func getDelegatorRewardDenoms() -> Array<String> {
        var result = Array<String>()
        delegator_claims.forEach { delegatorClaim in
            delegatorClaim.base_claim?.reward?.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
    
    public func getSwapRewardDenoms() -> Array<String> {
        var result = Array<String>()
        swap_claims.forEach { swapClaim in
            swapClaim.base_claim?.reward?.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
    
    public func getEarnRewardDenoms() -> Array<String> {
        var result = Array<String>()
        earn_claims.forEach { swapClaim in
            swapClaim.base_claim?.reward?.forEach({ coin in
                if (!result.contains(coin.denom)) {
                    result.append(coin.denom)
                }
            })
        }
        return result
    }
    
    
    
    
    
    public struct HardClaim {
        var base_claim: BaseClaim?
        
        init(_ dictionary: NSDictionary?) {
            if let rawBaseClaim = dictionary?["base_claim"] as? NSDictionary {
                self.base_claim = BaseClaim.init(rawBaseClaim)
            }
        }
    }
    
    
    
    public struct UsdxMintingClaim {
        var base_claim: MintBaseClaim?
        
        init(_ dictionary: NSDictionary?) {
            if let rawBaseClaim = dictionary?["base_claim"] as? NSDictionary {
                self.base_claim = MintBaseClaim.init(rawBaseClaim)
            }
        }
    }
    
    public struct DelegatorClaim {
        var base_claim: BaseClaim?
        
        init(_ dictionary: NSDictionary?) {
            if let rawBaseClaim = dictionary?["base_claim"] as? NSDictionary {
                self.base_claim = BaseClaim.init(rawBaseClaim)
            }
        }
        
    }
    
    public struct SwapClaim {
        var base_claim: BaseClaim?
        
        init(_ dictionary: NSDictionary?) {
            if let rawBaseClaim = dictionary?["base_claim"] as? NSDictionary {
                self.base_claim = BaseClaim.init(rawBaseClaim)
            }
        }
    }
    
    public struct EarnClaim {
        var base_claim: BaseClaim?
        
        init(_ dictionary: NSDictionary?) {
            if let rawBaseClaim = dictionary?["base_claim"] as? NSDictionary {
                self.base_claim = BaseClaim.init(rawBaseClaim)
            }
        }
    }
    
    public struct MintBaseClaim {
        var owner: String?
        var reward: Coin?

        init(_ dictionary: NSDictionary?) {
            self.owner = dictionary?["owner"] as? String
            if let rawCoin = dictionary?["reward"] as? NSDictionary  {
                self.reward = Coin.init(rawCoin)
            }
        }
    }
    
    public struct BaseClaim {
        var owner: String?
        var reward: Array<Coin>?

        init(_ dictionary: NSDictionary?) {
            self.owner = dictionary?["owner"] as? String
            if let rawCoins = dictionary?["reward"] as? Array<NSDictionary>  {
                self.reward = Array<Coin>()
                for rawCoin in rawCoins {
                    self.reward!.append(Coin(rawCoin))
                }
            }
        }
    }
}

