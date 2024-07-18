//
//  CosmosFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import SwiftProtobuf
import GRPC
import NIO
import SwiftyJSON
import Alamofire


class CosmosFetcher {
    
    var chain: BaseChain!
    
    var cosmosAccountNumber: UInt64?
    var cosmosSequenceNum: UInt64?
    var cosmosBalances: [Cosmos_Base_V1beta1_Coin]?
    var cosmosVestings = [Cosmos_Base_V1beta1_Coin]()
    var cosmosDelegations = [Cosmos_Staking_V1beta1_DelegationResponse]()
    var cosmosUnbondings: [Cosmos_Staking_V1beta1_UnbondingDelegation]?
    var cosmosRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]?
    var cosmosCommissions =  [Cosmos_Base_V1beta1_Coin]()
    var rewardAddress:  String?
    var cosmosValidators = [Cosmos_Staking_V1beta1_Validator]()
    var cosmosBaseFees = [Cosmos_Base_V1beta1_DecCoin]()
    
    var mintscanCw20Tokens = [MintscanToken]()
    var mintscanCw721List = [JSON]()
    var cw721Models = [Cw721Model]()
    
    
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchCosmosData(_ id: Int64) async -> Bool { return false }
    
    func fetchBalances() async -> Bool { return false }
    
    func fetchValidators() async -> Bool { return false }
    
    func fetchCosmosCw721() { }
    
    func fetchCosmosAuth() async {  }
    
    func fetchCosmosLastHeight() async throws -> Int64? { return nil }
    
    func fetchCosmosIbcClient(_ ibcPath: MintscanPath) async throws -> UInt64? { return nil }
    
    func fetchCosmosWasm(_ request: Cosmwasm_Wasm_V1_QuerySmartContractStateRequest) async throws -> JSON? { return nil }
    
    func fetchCosmosTx(_ txHash: String) async throws -> Cosmos_Tx_V1beta1_GetTxResponse? { return nil }
    
    func simulCosmosTx(_ simulTx: Cosmos_Tx_V1beta1_SimulateRequest) async throws -> UInt64? { return nil }
    
    func broadCastCosmosTx(_ tx: Cosmos_Tx_V1beta1_BroadcastTxRequest) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? { return nil }
    
    func updateBaseFee() async { }
    
    func onCheckCosmosVesting() { }
    
    
    
    
    
    
    
    
    func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == chain.stakeDenom) {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(delegationValueSum(usd)).adding(unbondingValueSum(usd)).adding(commissionValue(denom, usd))
            
        } else {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(commissionValue(denom, usd))
        }
    }
    
    func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(chain.stakeDenom!).adding(vestingAmount(chain.stakeDenom!)).adding(delegationAmountSum())
            .adding(unbondingAmountSum()).adding(rewardAmountSum(chain.stakeDenom!)).adding(commissionAmount(chain.stakeDenom!))
    }
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(vestingValueSum(usd)).adding(delegationValueSum(usd))
            .adding(unbondingValueSum(usd)).adding(rewardValueSum(usd)).adding(commissionValueSum(usd))
    }
    
    
    
    
    //For Neutron
    var vaultsList: [JSON]?
    var daosList: [JSON]?
    var neutronDeposited = NSDecimalNumber.zero
    var neutronVesting: JSON?
    
    func fetchVaultDeposit() async throws -> JSON? { return nil }
    func fetchNeutronVesting() async throws -> JSON? { return nil  }
    func fetchNeutronProposals(_ daoType: Int) async throws -> JSON? { return nil  }
    func neutronVestingAmount() -> NSDecimalNumber  { return NSDecimalNumber.zero }
    func neutronVestingValue(_ usd: Bool? = false) -> NSDecimalNumber  { return NSDecimalNumber.zero }
    func neutronDepositedValue(_ usd: Bool? = false) -> NSDecimalNumber  { return NSDecimalNumber.zero }
}


//about mintscan api
extension CosmosFetcher {
    func fetchCw20Info() async throws -> [MintscanToken]? {
        if (!chain.supportCw20) { return [] }
        return try await AF.request(BaseNetWork.msCw20InfoUrl(chain.apiName), method: .get).serializingDecodable([MintscanToken].self).value
    }
    
    func fetchCw721Info() async throws -> [JSON]? {
        if (!chain.supportCw721) { return [] }
        return try await AF.request(BaseNetWork.msCw721InfoUrl(chain.apiName), method: .get).serializingDecodable([JSON].self).value
    }
}


extension CosmosFetcher {
    func tokenValue(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (chain.supportCw20) {
            if let tokenInfo = mintscanCw20Tokens.filter({ $0.address == address }).first {
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
            }
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        if (chain.supportCw20) {
            mintscanCw20Tokens.forEach { tokenInfo in
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
        }
        return result
    }
    
    func valueCoinCnt() -> Int {
        return cosmosBalances?.filter({ BaseData.instance.getAsset(chain.apiName, $0.denom) != nil }).count ?? 0
    }
    
    func valueTokenCnt() -> Int {
        return mintscanCw20Tokens.filter {  $0.getAmount() != NSDecimalNumber.zero }.count
    }
    
    
    func balanceAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber(string: cosmosBalances?.filter { $0.denom == denom }.first?.amount ?? "0")
    }
    
    func balanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        let amount = balanceAmount(denom)
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func balanceValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        cosmosBalances?.forEach { balance in
            result = result.adding(balanceValue(balance.denom, usd))
        }
        return result
    }
    
    func vestingAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber(string: cosmosVestings.filter { $0.denom == denom }.first?.amount ?? "0")
    }
    
    func vestingValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = vestingAmount(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func vestingValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        cosmosVestings.forEach { vesting in
            result = result.adding(vestingValue(vesting.denom, usd))
        }
        return result
    }
    
    
    func delegationAmountSum() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        cosmosDelegations.forEach({ delegation in
            sum = sum.adding(NSDecimalNumber(string: delegation.balance.amount))
        })
        return sum
    }
    
    func delegationValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = delegationAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func unbondingAmountSum() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        cosmosUnbondings?.forEach({ unbonding in
            for entry in unbonding.entries {
                sum = sum.adding(NSDecimalNumber(string: entry.balance))
            }
        })
        return sum
    }
    
    func unbondingValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = unbondingAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    
    func rewardAmountSum(_ denom: String) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        cosmosRewards?.forEach({ reward in
            result = result.adding(NSDecimalNumber(string: reward.reward.filter{ $0.denom == denom }.first?.amount ?? "0"))
        })
        return result.multiplying(byPowerOf10: -18, withBehavior: handler0Down)
    }
    
    func rewardValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = rewardAmountSum(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func rewardAllCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        cosmosRewards?.forEach({ reward in
            reward.reward.forEach { deCoin in
                if BaseData.instance.getAsset(chain.apiName, deCoin.denom) != nil {
                    let deCoinAmount = deCoin.getAmount()
                    if (deCoinAmount != NSDecimalNumber.zero) {
                        if let index = result.firstIndex(where: { $0.denom == deCoin.denom }) {
                            let exist = NSDecimalNumber(string: result[index].amount)
                            let addes = exist.adding(deCoinAmount)
                            result[index].amount = addes.stringValue
                        } else {
                            result.append(Cosmos_Base_V1beta1_Coin(deCoin.denom, deCoinAmount))
                        }
                    }
                }
            }
        })
        return result
    }
    
    func rewardOtherDenomTypeCnts() -> Int {
        var denoms = [String]()
        rewardAllCoins().filter { $0.denom != chain.stakeDenom }.forEach { reward in
            if (denoms.contains(reward.denom) == false) {
                denoms.append(reward.denom)
            }
        }
        return denoms.count
    }
    
    func rewardValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        rewardAllCoins().forEach { rewardCoin in
            if let msAsset = BaseData.instance.getAsset(chain.apiName, rewardCoin.denom) {
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
                let amount = NSDecimalNumber(string: rewardCoin.amount)
                let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
        }
        return result
    }
    
    func claimableRewards() -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward] {
        var result = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
        cosmosRewards?.forEach { reward in
            for i in 0..<reward.reward.count {
                let rewardAmount = NSDecimalNumber(string: reward.reward[i].amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                if let msAsset = BaseData.instance.getAsset(chain.apiName, reward.reward[i].denom) {
                    let calAmount = rewardAmount.multiplying(byPowerOf10: -msAsset.decimals!)
                    if (calAmount.compare(NSDecimalNumber.init(string: "0.1")).rawValue > 0) {
                        result.append(reward)
                        break
                    }
                }
            }
            return
        }
        return result
    }
    
    func valueableRewards() -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward] {
        var result = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
        cosmosRewards?.forEach { reward in
            var eachRewardValue = NSDecimalNumber.zero
            for i in 0..<reward.reward.count {
                let rewardAmount = NSDecimalNumber(string: reward.reward[i].amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                if let msAsset = BaseData.instance.getAsset(chain.apiName, reward.reward[i].denom) {
                    let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, true)
                    let value = msPrice.multiplying(by: rewardAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                    eachRewardValue = eachRewardValue.adding(value)
                    if (eachRewardValue.compare(NSDecimalNumber.init(string: "0.1")).rawValue >= 0) {
                        result.append(reward)
                        break
                    }
                }
            }
        }
        return result
    }
    
    func compoundableRewards() -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward] {
        var result = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
        cosmosRewards?.forEach { reward in
            if let rewardAmount = reward.reward.filter({ $0.denom == chain.stakeDenom }).first?.getAmount(),
               let msAsset = BaseData.instance.getAsset(chain.apiName, chain.stakeDenom!) {
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, true)
                let value = msPrice.multiplying(by: rewardAmount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
                if (value.compare(NSDecimalNumber.init(string: "0.1")).rawValue >= 0) {
                    result.append(reward)
                }
            }
        }
        return result
    }
    
    func commissionAmount(_ denom: String) -> NSDecimalNumber {
        return cosmosCommissions.filter { $0.denom == denom }.first?.getAmount() ?? NSDecimalNumber.zero
    }
    
    func commissionValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = cosmosCommissions.filter { $0.denom == denom }.first?.getAmount() ?? NSDecimalNumber.zero
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func commissionValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        cosmosCommissions.forEach { commi in
            result = result.adding(commissionValue(commi.denom, usd))
        }
        return result
    }
    
    func commissionOtherDenoms() -> Int {
        return cosmosCommissions.filter { $0.denom != chain.stakeDenom }.count
    }
}
