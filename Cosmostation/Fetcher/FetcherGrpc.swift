//
//  FetcherGrpc.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import SwiftProtobuf
import GRPC
import NIO
import SwiftyJSON
import Alamofire

class FetcherGrpc {
    
    var chain: BaseChain!
    
    var cosmosAuth: Google_Protobuf_Any?
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
    
    var grpcConnection: ClientConnection!
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    deinit {
        try? grpcConnection.close()
    }
    
    func fetchBalances() async -> Bool {
        cosmosBalances = [Cosmos_Base_V1beta1_Coin]()
        if let auth = try? await fetchAuth(),
           let balance = try? await fetchBalance() {
            self.cosmosAuth = auth
            self.cosmosBalances = balance
            self.onCheckVesting()
        }
        return true
    }
    
    
    func fetchGrpcData(_ id: Int64) async -> Bool {
        mintscanCw20Tokens.removeAll()
        mintscanCw721List.removeAll()
        cosmosAuth = nil
        cosmosBalances = nil
        cosmosVestings.removeAll()
        cosmosDelegations.removeAll()
        cosmosUnbondings = nil
        cosmosRewards = nil
        cosmosCommissions.removeAll()
        rewardAddress = nil
        cosmosBaseFees.removeAll()
        
        do {
            if let cw20Tokens = try? await fetchCw20Info(),
               let cw721List = try? await fetchCw721Info(),
               let balance = try await fetchBalance(),
               let auth = try? await fetchAuth(),
               let delegations = try? await fetchDelegation(),
               let unbonding = try? await fetchUnbondings(),
               let rewards = try? await fetchRewards(),
               let commission = try? await fetchCommission(),
               let rewardaddr = try? await fetchRewardAddress(),
               let baseFees = try? await fetchBaseFee() {
                self.mintscanCw20Tokens = cw20Tokens ?? []
                self.mintscanCw721List = cw721List ?? []
                self.cosmosAuth = auth
                self.cosmosBalances = balance
                delegations?.forEach({ delegation in
                    if (delegation.balance.amount != "0") {
                        self.cosmosDelegations.append(delegation)
                    }
                })
                self.cosmosUnbondings = unbonding
                self.cosmosRewards = rewards
                commission?.commission.forEach { commi in
                    if (commi.getAmount().compare(NSDecimalNumber.zero).rawValue > 0) {
                        self.cosmosCommissions.append(Cosmos_Base_V1beta1_Coin(commi.denom, commi.getAmount()))
                    }
                }
                self.rewardAddress = rewardaddr?.replacingOccurrences(of: "\"", with: "")
                
                baseFees?.forEach({ basefee in
                    if (BaseData.instance.getAsset(chain.apiName, basefee.denom) != nil) {
                        self.cosmosBaseFees.append(basefee)
                    }
                })
                self.cosmosBaseFees.sort {
                    if ($0.denom == chain.stakeDenom) { return true }
                    if ($1.denom == chain.stakeDenom) { return false }
                    return false
                }
                
                await mintscanCw20Tokens.concurrentForEach { cw20 in
                    self.fetchCw20Balance(cw20)
                }
            }
            return true
            
        } catch {
            print("grpc error \(error) ", chain.tag)
            return false
        }
        
    }
    
    func fetchValidators() async -> Bool {
        if (cosmosValidators.count > 0) { return true }
        
        if let bonded = try? await fetchBondedValidator(),
           let unbonding = try? await fetchUnbondingValidator(),
           let unbonded = try? await fetchUnbondedValidator() {
            
            cosmosValidators.append(contentsOf: bonded ?? [])
            cosmosValidators.append(contentsOf: unbonding ?? [])
            cosmosValidators.append(contentsOf: unbonded ?? [])
            
            cosmosValidators.sort {
                if ($0.description_p.moniker == "Cosmostation") { return true }
                if ($1.description_p.moniker == "Cosmostation") { return false }
                if ($0.jailed && !$1.jailed) { return false }
                if (!$0.jailed && $1.jailed) { return true }
                return Double($0.tokens)! > Double($1.tokens)!
            }
            return true
        }
        return false
    }
    
    
    
    func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(chain.stakeDenom!).adding(vestingAmount(chain.stakeDenom!)).adding(delegationAmountSum())
            .adding(unbondingAmountSum()).adding(rewardAmountSum(chain.stakeDenom!)).adding(commissionAmount(chain.stakeDenom!))
    }
    
    func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == chain.stakeDenom) {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(delegationValueSum(usd)).adding(unbondingValueSum(usd)).adding(commissionValue(denom, usd))
            
        } else {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(commissionValue(denom, usd))
        }
    }
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(vestingValueSum(usd)).adding(delegationValueSum(usd))
            .adding(unbondingValueSum(usd)).adding(rewardValueSum(usd)).adding(commissionValueSum(usd))
    }
    
    
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


//about mintscan api
extension FetcherGrpc {
    func fetchCw20Info() async throws -> [MintscanToken]? {
        if (!chain.supportCw20) { return [] }
        return try await AF.request(BaseNetWork.msCw20InfoUrl(chain.apiName), method: .get).serializingDecodable([MintscanToken].self).value
    }
    
    func fetchCw721Info() async throws -> [JSON]? {
        if (!chain.supportCw721) { return [] }
        return try await AF.request(BaseNetWork.msCw721InfoUrl(chain.apiName), method: .get).serializingDecodable([JSON].self).value
    }
    
}

//about common grpc call
extension FetcherGrpc {
    
    func fetchBondedValidator() async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
    }
    
    func fetchUnbondedValidator() async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDED" }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
    }
    
    func fetchUnbondingValidator() async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDING" }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: getClient()).validators(req).response.get().validators
    }
    
    func fetchAuth() async throws -> Google_Protobuf_Any? {
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = chain.bechAddress! }
        return try? await Cosmos_Auth_V1beta1_QueryNIOClient(channel: getClient()).account(req, callOptions: getCallOptions()).response.get().account
    }
    
    func fetchBalance() async throws -> [Cosmos_Base_V1beta1_Coin]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = chain.bechAddress!; $0.pagination = page }
        return try await Cosmos_Bank_V1beta1_QueryNIOClient(channel: getClient()).allBalances(req, callOptions: getCallOptions()).response.get().balances
    }
    
    func fetchDelegation() async throws -> [Cosmos_Staking_V1beta1_DelegationResponse]? {
        let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
        return try? await Cosmos_Staking_V1beta1_QueryNIOClient(channel: getClient()).delegatorDelegations(req, callOptions: getCallOptions()).response.get().delegationResponses
    }
    
    func fetchUnbondings() async throws -> [Cosmos_Staking_V1beta1_UnbondingDelegation]? {
        let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
        return try? await Cosmos_Staking_V1beta1_QueryNIOClient(channel: getClient()).delegatorUnbondingDelegations(req, callOptions: getCallOptions()).response.get().unbondingResponses
    }
    
    func fetchRewards() async throws -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]? {
        let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = chain.bechAddress! }
        return try? await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: getClient()).delegationTotalRewards(req, callOptions: getCallOptions()).response.get().rewards
    }
    
    func fetchCommission() async throws -> Cosmos_Distribution_V1beta1_ValidatorAccumulatedCommission? {
        if (chain.bechOpAddress == nil) { return nil }
        let req = Cosmos_Distribution_V1beta1_QueryValidatorCommissionRequest.with { $0.validatorAddress = chain.bechOpAddress! }
        return try? await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: getClient()).validatorCommission(req, callOptions: getCallOptions()).response.get().commission
    }
    
    func fetchRewardAddress() async throws -> String? {
        let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with { $0.delegatorAddress = chain.bechAddress! }
        return try? await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: getClient()).delegatorWithdrawAddress(req, callOptions: getCallOptions()).response.get().withdrawAddress
    }
    
    func simulateTx(_ simulTx: Cosmos_Tx_V1beta1_SimulateRequest) async throws -> Cosmos_Tx_V1beta1_SimulateResponse? {
        return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: getClient()).simulate(simulTx, callOptions: getCallOptions()).response.get()
    }
    
    func broadcastTx(_ broadTx: Cosmos_Tx_V1beta1_BroadcastTxRequest) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        return try? await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: getClient()).broadcastTx(broadTx, callOptions: getCallOptions()).response.get().txResponse
    }
    
    func fetchTx( _ hash: String) async throws -> Cosmos_Tx_V1beta1_GetTxResponse? {
        let req = Cosmos_Tx_V1beta1_GetTxRequest.with { $0.hash = hash }
        return try await Cosmos_Tx_V1beta1_ServiceNIOClient(channel: getClient()).getTx(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchIbcClient(_ ibcPath: MintscanPath) async throws -> Ibc_Core_Channel_V1_QueryChannelClientStateResponse? {
        let req = Ibc_Core_Channel_V1_QueryChannelClientStateRequest.with {
            $0.channelID = ibcPath.channel!
            $0.portID = ibcPath.port!
        }
        return try? await Ibc_Core_Channel_V1_QueryNIOClient(channel: getClient()).channelClientState(req, callOptions: getCallOptions()).response.get()
    }
    
    func fetchLastBlock() async throws -> Cosmos_Base_Tendermint_V1beta1_GetLatestBlockResponse? {
        let req = Cosmos_Base_Tendermint_V1beta1_GetLatestBlockRequest()
        return try? await Cosmos_Base_Tendermint_V1beta1_ServiceNIOClient(channel: getClient()).getLatestBlock(req, callOptions: getCallOptions()).response.get()
    }
    
    
    func fetchAllCw20Balance(_ id: Int64) async {
//        print("fetchAllCw20Balance")
        if (chain.supportCw20 == false) { return }
        Task {
            await mintscanCw20Tokens.concurrentForEach { cw20 in
                self.fetchCw20Balance(cw20)
            }
        }
    }
    
    func fetchCw20Balance(_ tokenInfo: MintscanToken) {
        let query: JSON = ["balance" : ["address" : self.chain.bechAddress!]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = tokenInfo.address!
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let response = try? Cosmwasm_Wasm_V1_QueryNIOClient(channel: getClient()).smartContractState(req, callOptions: self.getCallOptions()).response.wait() {
            let cw20balance = try? JSONDecoder().decode(JSON.self, from: response.data)
//            print("fetchCw20Balance ", tokenInfo.symbol, "  ", cw20balance?["balance"].string)
            tokenInfo.setAmount(cw20balance?["balance"].string ?? "0")
        }
    }
    
    func fetchAllCw721() {
        cw721Models.removeAll()
        Task {
            await mintscanCw721List.concurrentForEach { list in
                var tokens = [Cw721TokenModel]()
                if let tokenIds = try? await self.fetchCw721TokenIds(list), !tokenIds.isEmpty {
                    await tokenIds["tokens"].arrayValue.concurrentForEach { tokenId in
                        if let tokenInfo = try? await self.fetchCw721TokenInfo(list, tokenId.stringValue) {
                            let tokenDetail = try? await AF.request(BaseNetWork.msNftDetail(self.chain.apiName, list["contractAddress"].stringValue, tokenId.stringValue), method: .get).serializingDecodable(JSON.self).value
                            tokens.append(Cw721TokenModel.init(tokenId.stringValue, tokenInfo, tokenDetail))
                        }
                    }
                }
                if (!tokens.isEmpty) {
                    self.cw721Models.append(Cw721Model(list, tokens))
                }
            }
            DispatchQueue.main.async(execute: {
                self.cw721Models.sort {
                    return $0.info["id"].doubleValue < $1.info["id"].doubleValue
                }
                self.cw721Models.forEach { cw721Model in
                    cw721Model.sortId()
                }
                NotificationCenter.default.post(name: Notification.Name("FetchNFTs"), object: self.chain.tag, userInfo: nil)
            })
        }
        
    }
    
    func fetchCw721TokenIds(_ list: JSON) async throws -> JSON {
        let query: JSON = ["tokens" : ["owner" : self.chain.bechAddress!, "limit" : 50, "start_after" : "0"]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = list["contractAddress"].stringValue
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let result = try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: getClient()).smartContractState(req, callOptions: getCallOptions()).response.get().data,
           let tokenIds = try? JSONDecoder().decode(JSON.self, from: result), tokenIds["tokens"].arrayValue.count > 0 {
            return tokenIds
        }
        return JSON()
    }
    
    func fetchCw721TokenInfo(_ list: JSON, _ tokenId: String) async throws -> JSON {
        let query: JSON = ["nft_info" : ["token_id" : tokenId]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = list["contractAddress"].stringValue
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let result = try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: getClient()).smartContractState(req, callOptions: getCallOptions()).response.get().data,
           let tokenInfo = try? JSONDecoder().decode(JSON.self, from: result) {
            return tokenInfo
        }
        return JSON()
    }
    
    func fetchBaseFee() async throws -> [Cosmos_Base_V1beta1_DecCoin]? {
        if (!chain.supportFeeMarket()) { return nil }
        let req = Feemarket_Feemarket_V1_GasPricesRequest.init()
        return try? await Feemarket_Feemarket_V1_QueryNIOClient(channel: getClient()).gasPrices(req, callOptions: getCallOptions()).response.get().prices
    }
    
    func updateBaseFee() async {
        cosmosBaseFees.removeAll()
        if (!chain.supportFeeMarket()) { return }
        let req = Feemarket_Feemarket_V1_GasPricesRequest.init()
        if let baseFees = try? await Feemarket_Feemarket_V1_QueryNIOClient(channel: getClient()).gasPrices(req, callOptions: getCallOptions()).response.get().prices {
            baseFees.forEach({ basefee in
                if (BaseData.instance.getAsset(chain.apiName, basefee.denom) != nil) {
                    self.cosmosBaseFees.append(basefee)
                }
            })
            self.cosmosBaseFees.sort {
                if ($0.denom == chain.stakeDenom) { return true }
                if ($1.denom == chain.stakeDenom) { return false }
                return false
            }
        }
    }
    
    
    
    func getGrpc() -> (host: String, port: Int) {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_GRPC_ENDPOINT +  " : " + chain.name) {
            if (endpoint.components(separatedBy: ":").count == 2) {
                let host = endpoint.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                let port = Int(endpoint.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
                return (host, port!)
            }
        }
        return (chain.grpcHost, chain.grpcPort)
    }
    
    func getClient() -> ClientConnection {
        if (grpcConnection == nil) {
            let group = PlatformSupport.makeEventLoopGroup(loopCount: 4)
            grpcConnection = ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: getGrpc().host, port: getGrpc().port)
        }
        return grpcConnection
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(5000))
        return callOptions
    }
}


extension FetcherGrpc {
    
    func onCheckVesting() {
        guard let authInfo = cosmosAuth else {
            return
        }
        
        if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)),
           let vestingAccount = try? Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: authInfo.value) {

            cosmosBalances?.forEach({ coin in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero

                dpBalance = NSDecimalNumber.init(string: coin.amount)

                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                remainVesting = onParsePeriodicRemainVestingsAmountByDenom(vestingAccount, denom)

                dpVesting = remainVesting.subtracting(delegatedVesting)

                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting

                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(cosmosBalances?.count ?? 0) {
                        if (cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })

        } else if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)),
                    let vestingAccount = try? Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: authInfo.value) {

            cosmosBalances?.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingStart = vestingAccount.startTime * 1000
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
                if (cTime < vestingStart) {
                    remainVesting = originalVesting
                } else if (cTime > vestingEnd) {
                    remainVesting = NSDecimalNumber.zero
                } else {
                    let progress = ((Float)(cTime - vestingStart)) / ((Float)(vestingEnd - vestingStart))
                    remainVesting = originalVesting.multiplying(by: NSDecimalNumber.init(value: 1 - progress), withBehavior: handler0Up)
                }
                
                dpVesting = remainVesting.subtracting(delegatedVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting)
                }
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(cosmosBalances?.count ?? 0) {
                        if (cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })

        } else if (authInfo.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)),
                    let vestingAccount = try? Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: authInfo.value) {

            cosmosBalances?.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                let cTime = Date().millisecondsSince1970
                let vestingEnd = vestingAccount.baseVestingAccount.endTime * 1000
                if (cTime < vestingEnd) {
                    remainVesting = originalVesting
                }
                
                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                dpVesting = remainVesting.subtracting(delegatedVesting)
                
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (remainVesting.compare(delegatedVesting).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(cosmosBalances?.count ?? 0) {
                        if (cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })

        } else if (authInfo.typeURL.contains(Stride_Vesting_StridePeriodicVestingAccount.protoMessageName)),
                  let vestingAccount = try? Stride_Vesting_StridePeriodicVestingAccount.init(serializedData: authInfo.value) {
            
            cosmosBalances?.forEach({ (coin) in
                let denom = coin.denom
                var dpBalance = NSDecimalNumber.zero
                var dpVesting = NSDecimalNumber.zero
                var originalVesting = NSDecimalNumber.zero
                var remainVesting = NSDecimalNumber.zero
                var delegatedVesting = NSDecimalNumber.zero
                var delegatedFree = NSDecimalNumber.zero
                
                dpBalance = NSDecimalNumber.init(string: coin.amount)
                
                vestingAccount.baseVestingAccount.originalVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        originalVesting = originalVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                vestingAccount.baseVestingAccount.delegatedVesting.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedVesting = delegatedVesting.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })

                vestingAccount.baseVestingAccount.delegatedFree.forEach({ (coin) in
                    if (coin.denom == denom) {
                        delegatedFree = delegatedFree.adding(NSDecimalNumber.init(string: coin.amount))
                    }
                })
                
                remainVesting = onParseStridePeriodicRemainVestingsAmountByDenom(vestingAccount, denom)
                dpVesting = remainVesting.subtracting(delegatedVesting).subtracting(delegatedFree);
                dpVesting = dpVesting.compare(NSDecimalNumber.zero).rawValue <= 0 ? NSDecimalNumber.zero : dpVesting
                
                if (remainVesting.compare(delegatedVesting.adding(delegatedFree)).rawValue > 0) {
                    dpBalance = dpBalance.subtracting(remainVesting).adding(delegatedVesting);
                }
                
                if (dpVesting.compare(NSDecimalNumber.zero).rawValue > 0) {
                    let vestingCoin = Cosmos_Base_V1beta1_Coin.with { $0.denom = denom; $0.amount = dpVesting.stringValue }
                    cosmosVestings.append(vestingCoin)
                    var replace = -1
                    for i in 0..<(cosmosBalances?.count ?? 0) {
                        if (cosmosBalances![i].denom == denom) {
                            replace = i
                        }
                    }
                    if (replace >= 0) {
                        cosmosBalances![replace] = Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = dpBalance.stringValue }
                    }
                }
            })
        }
        
    }
    
    
    func onParsePeriodicRemainVestingsAmountByDenom(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String) -> NSDecimalNumber {
        var results = NSDecimalNumber.zero
        let periods = onParsePeriodicRemainVestingsByDenom(vestingAccount, denom)
        for vp in periods {
            for coin in vp.amount {
                if (coin.denom ==  denom) {
                    results = results.adding(NSDecimalNumber.init(string: coin.amount))
                }
            }
        }
        return results
    }
    
    func onParsePeriodicRemainVestingsByDenom(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ denom: String) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        for vp in onParsePeriodicRemainVestings(vestingAccount) {
            for coin in vp.amount {
                if (coin.denom ==  denom) {
                    results.append(vp)
                }
            }
        }
        return results
    }
    
    func onParsePeriodicRemainVestings(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        let cTime = Date().millisecondsSince1970
        for i in 0..<vestingAccount.vestingPeriods.count {
            let unlockTime = onParsePeriodicUnLockTime(vestingAccount, i)
            if (cTime < unlockTime) {
                let temp = Cosmos_Vesting_V1beta1_Period.with {
                    $0.length = unlockTime
                    $0.amount = vestingAccount.vestingPeriods[i].amount
                }
                results.append(temp)
            }
        }
        return results
    }
    
    func onParseStridePeriodicRemainVestingsByDenom(_ vestingAccount: Stride_Vesting_StridePeriodicVestingAccount, _ denom: String) -> Array<Cosmos_Vesting_V1beta1_Period> {
        var results = Array<Cosmos_Vesting_V1beta1_Period>()
        let cTime = Date().millisecondsSince1970
        vestingAccount.vestingPeriods.forEach { (period) in
            let vestingEnd = (period.startTime + period.length) * 1000
            if cTime < vestingEnd {
                period.amount.forEach { (vesting) in
                    if (vesting.denom == denom) {
                        let temp = Cosmos_Vesting_V1beta1_Period.with {
                            $0.length = vestingEnd
                            $0.amount = period.amount
                        }
                        results.append(temp)
                    }
                }
            }
        }
        return results
    }
    
    func onParseStridePeriodicRemainVestingsAmountByDenom(_ vestingAccount: Stride_Vesting_StridePeriodicVestingAccount, _ denom: String) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        let vpList = onParseStridePeriodicRemainVestingsByDenom(vestingAccount, denom)
        vpList.forEach { (vp) in
            vp.amount.forEach { (coin) in
                if (coin.denom == denom) {
                    result = result.adding(NSDecimalNumber.init(string: coin.amount))
                }
            }
        }
        return result
    }
    
    func onParsePeriodicUnLockTime(_ vestingAccount: Cosmos_Vesting_V1beta1_PeriodicVestingAccount, _ position: Int) -> Int64 {
        var result = vestingAccount.startTime
        for i in 0..<(position + 1) {
            result = result + vestingAccount.vestingPeriods[i].length
        }
        return result * 1000
    }
}


extension Google_Protobuf_Any {
    
    func accountInfos() -> (address: String?, accountNum: UInt64?, sequenceNum: UInt64?) {
        
        var rawAccount = self
        if (typeURL.contains(Desmos_Profiles_V3_Profile.protoMessageName)),
            let account = try? Desmos_Profiles_V3_Profile.init(serializedData: value).account {
            rawAccount = account
        }
        
        if (rawAccount.typeURL.contains(Cosmos_Auth_V1beta1_BaseAccount.protoMessageName)),
           let auth = try? Cosmos_Auth_V1beta1_BaseAccount.init(serializedData: rawAccount.value) {
            return (auth.address, auth.accountNumber, auth.sequence)

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)),
                  let auth = try? Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)),
                    let auth = try? Ethermint_Types_V1_EthAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)

        } else if (rawAccount.typeURL.contains(Stride_Vesting_StridePeriodicVestingAccount.protoMessageName)),
                  let auth = try? Stride_Vesting_StridePeriodicVestingAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseVestingAccount.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)
            
        } else if (rawAccount.typeURL.contains(Artela_Types_V1_EthAccount.protoMessageName)),
                  let auth = try? Artela_Types_V1_EthAccount.init(serializedData: rawAccount.value) {
            let baseAccount = auth.baseAccount
            return (baseAccount.address, baseAccount.accountNumber, baseAccount.sequence)
        }
        
        return (nil, nil, nil)
    }
    
    func onParseAuthPubkeyType() -> String? {
        
        var rawAccount = self
        if (typeURL.contains(Desmos_Profiles_V3_Profile.protoMessageName)),
            let account = try? Desmos_Profiles_V3_Profile.init(serializedData: rawAccount.value).account {
            rawAccount = account
        }

        if (rawAccount.typeURL.contains(Cosmos_Auth_V1beta1_BaseAccount.protoMessageName)),
           let auth = try? Cosmos_Auth_V1beta1_BaseAccount.init(serializedData: rawAccount.value) {
            return auth.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_PeriodicVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_PeriodicVestingAccount.init(serializedData: rawAccount.value) {
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_ContinuousVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_ContinuousVestingAccount.init(serializedData: rawAccount.value) {
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Cosmos_Vesting_V1beta1_DelayedVestingAccount.protoMessageName)),
                  let auth = try? Cosmos_Vesting_V1beta1_DelayedVestingAccount.init(serializedData: rawAccount.value) {
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Injective_Types_V1beta1_EthAccount.protoMessageName)),
                  let auth = try? Injective_Types_V1beta1_EthAccount.init(serializedData: rawAccount.value) {
            return auth.baseAccount.pubKey.typeURL

        } else if (rawAccount.typeURL.contains(Ethermint_Types_V1_EthAccount.protoMessageName)),
                    let auth = try? Ethermint_Types_V1_EthAccount.init(serializedData: rawAccount.value) {
            return auth.baseAccount.pubKey.typeURL

        }  else if (rawAccount.typeURL.contains(Stride_Vesting_StridePeriodicVestingAccount.protoMessageName)),
                  let auth = try? Stride_Vesting_StridePeriodicVestingAccount.init(serializedData: rawAccount.value) {
            return auth.baseVestingAccount.baseAccount.pubKey.typeURL
        }
        return nil
    }
    
}
