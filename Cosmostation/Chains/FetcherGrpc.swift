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
    
    var mintscanCw20Tokens = [MintscanToken]()
    var mintscanCw721List = [JSON]()
    var cw721Models = [Cw721Model]()
    var cw721Fetched = false
    
    var grpcConnection: ClientConnection!
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    deinit {
        try? grpcConnection.close()
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
        
        do {
            if let cw20Tokens = try? await fetchCw20Info(),
               let cw721List = try? await fetchCw721Info(),
               let auth = try? await fetchAuth(),
               let balance = try await fetchBalance(),
               let delegations = try? await fetchDelegation(),
               let unbonding = try? await fetchUnbondings(),
               let rewards = try? await fetchRewards(),
               let commission = try? await fetchCommission(),
               let rewardaddr = try? await fetchRewardAddress() {
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
                
//                print("fetchAllCw20Balance start ", chain.tag)
                await mintscanCw20Tokens.concurrentForEach { cw20 in
                    self.fetchCw20Balance(cw20)
                }
//                print("fetchAllCw20Balance end ", chain.tag)
            }
            return true
            
        } catch {
            print("grpc error \(error)")
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
        return try await Cosmos_Auth_V1beta1_QueryNIOClient(channel: getClient()).account(req, callOptions: getCallOptions()).response.get().account
    }
    
    func fetchBalance() async throws -> [Cosmos_Base_V1beta1_Coin]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = chain.bechAddress!; $0.pagination = page }
        return try await Cosmos_Bank_V1beta1_QueryNIOClient(channel: getClient()).allBalances(req, callOptions: getCallOptions()).response.get().balances
    }
    
    func fetchDelegation() async throws -> [Cosmos_Staking_V1beta1_DelegationResponse]? {
        let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: getClient()).delegatorDelegations(req, callOptions: getCallOptions()).response.get().delegationResponses
    }
    
    func fetchUnbondings() async throws -> [Cosmos_Staking_V1beta1_UnbondingDelegation]? {
        let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = chain.bechAddress! }
        return try? await Cosmos_Staking_V1beta1_QueryNIOClient(channel: getClient()).delegatorUnbondingDelegations(req, callOptions: getCallOptions()).response.get().unbondingResponses
    }
    
    func fetchRewards() async throws -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]? {
        let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = chain.bechAddress! }
        return try await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: getClient()).delegationTotalRewards(req, callOptions: getCallOptions()).response.get().rewards
    }
    
    func fetchCommission() async throws -> Cosmos_Distribution_V1beta1_ValidatorAccumulatedCommission? {
        if (chain.bechOpAddress == nil) { return nil }
        let req = Cosmos_Distribution_V1beta1_QueryValidatorCommissionRequest.with { $0.validatorAddress = chain.bechOpAddress! }
        return try? await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: getClient()).validatorCommission(req, callOptions: getCallOptions()).response.get().commission
    }
    
    func fetchRewardAddress() async throws -> String? {
        let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with { $0.delegatorAddress = chain.bechOpAddress! }
        return try? await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: getClient()).delegatorWithdrawAddress(req, callOptions: getCallOptions()).response.get().withdrawAddress
    }
    
    func fetchAllCw20Balance(_ id: Int64) async {
        print("fetchAllCw20Balance in start")
        if (chain.supportCw20 == false) { return }
        Task {
            await mintscanCw20Tokens.concurrentForEach { cw20 in
                self.fetchCw20Balance(cw20)
            }
        }
        print("fetchAllCw20Balance in end")
//        mintscanCw20Tokens.forEach { cw20 in
//            Task {
//                self.fetchCw20Balance(cw20)
//            }
//        }
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
        cw721Fetched = false
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
                self.cw721Fetched = true
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
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(8000))
        return callOptions
    }
}


//enum CommonError: String, Error {
//  case grpcError = "grpc error."
//  case evmErrpr = "evm error."
//}
