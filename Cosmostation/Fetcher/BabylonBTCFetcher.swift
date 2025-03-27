//
//  BabylonBTCFetcher.swift
//  Cosmostation
//
//  Created by 차소민 on 2/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import GRPC
import NIO

// MARK: BTC staking
class BabylonBTCFetcher {
    var chain: BaseChain!

    var btcDelegations = [BtcDelegation]()
    var btcStakingAmount: NSDecimalNumber = .zero
    var btcUnstakingAmount: NSDecimalNumber = .zero
    var btcWithdrawableAmount: NSDecimalNumber = .zero
    var finalityProviders = [FinalityProvider]()
    var btcStakedRewards = [Cosmos_Base_V1beta1_Coin]()

    var btcStakingTimeLockWeeks = 0
    var btcUnbondingTimeDays = 0
    
    var grpcConnection: ClientConnection?

    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    
    func fetchBtcStakingData() async -> Bool {
        btcDelegations = []
        btcStakedRewards = []
        
        var delegations: [JSON] = []
        
        do {
            // babylon
            if let chain = (chain as? ChainBabylon) {
                delegations = try await fetchBtcDelegations(chain.bechAddress!)
                btcStakingAmount = NSDecimalNumber(value: delegations.filter({ $0["status_desc"] == "ACTIVE" }).map({ UInt64($0["total_sat"].stringValue) ?? 0 }).reduce(0, +))
                btcStakedRewards = await fetchBtcStakedRewards()
                
            //bitcoin
            } else if let chain = (chain as? ChainBitCoin86),
                      chain.isSupportBTCStaking() {
                if let delegationsResult = try await fetchBtcDelegations() {
                    delegations = delegationsResult
                } else {
                    return false
                }
                
                if let params = try await fetchParams() {
                    let blockPerHour = 6.0
                    
                    let stakingBlock = Double(params.maxStakingTimeBlocks)
                    let stakingHour = stakingBlock / blockPerHour
                    btcStakingTimeLockWeeks = Int((stakingHour / 24 / 7 / 5).rounded() * 5)
                    
                    let unbondingBlock = Double(params.unbondingTimeBlocks)
                    let unbondingHour = unbondingBlock / blockPerHour
                    btcUnbondingTimeDays = Int((unbondingHour / 24))
                }
                if finalityProviders.isEmpty {
                    delegations.forEach { delegation in
                        self.btcDelegations.append(BtcDelegation.init(delegation, nil))
                    }
                } else {
                    delegations.forEach { delegation in
                        let provider = finalityProviders.filter({ $0.btcPk == delegation["finality_provider_btc_pks_hex"].array?.first?.stringValue}).first
                        self.btcDelegations.append(BtcDelegation.init(delegation, provider))
                    }
                }
                
                let stakingAmount = btcDelegations.filter({ $0.state.uppercased() == "ACTIVE"}).map({ $0.amount }).reduce(0, +)
                btcStakingAmount = NSDecimalNumber(integerLiteral: stakingAmount)
                let unstakingAmount = btcDelegations.filter({ $0.state.uppercased() == "EARLY_UNBONDING" }).map({ $0.amount }).reduce(0, +)
                btcUnstakingAmount = NSDecimalNumber(integerLiteral: unstakingAmount)
                let withdrawableAmount = btcDelegations.filter({ $0.state.uppercased() == "EARLY_UNBONDING_WITHDRAWABLE" }).map({ $0.amount }).reduce(0, +)
                btcWithdrawableAmount = NSDecimalNumber(integerLiteral: withdrawableAmount)
                
                btcDelegations.sort {
                    if let a = WUtils.timeStringToDate($0.inceptionTime),
                       let b = WUtils.timeStringToDate($1.inceptionTime) {
                        return a > b
                    } else {
                        return true
                    }
                }
            }
            
            return true

        } catch {
            print("fetchBtcStakingData error \(error)")
            return false
        }
    }
    
    func fetchFinalityProvidersInfo() async -> Bool {
        if (!finalityProviders.isEmpty) { return true }

        do {
            try await fetchFinalityProviders().forEach { provider in
                self.finalityProviders.append(FinalityProvider(provider, "0"))
                
                for (index, delegation) in btcDelegations.enumerated() {
                    if let provider = finalityProviders.filter({ $0.btcPk == delegation.providerPk }).first {
                        btcDelegations[index].updateDelegationProviderInfo(provider)
                    }
                }

            }
            return true
            
        } catch {
            print("fetchFinalityProvidersInfo error \(error)")
            return false
        }
    }
    
    func updateProvidersVotingPower() async {
        do {
            let height = try await fetchStatusHeight()
            let votingPowerList = try await fetchProvidersVotingPower(height)
            
            for (index, provider) in finalityProviders.enumerated() {
                let btcPk = provider.btcPk
                if let votingPower = votingPowerList.filter({ $0.btcPkHex == btcPk }).first?.votingPower {
                    finalityProviders[index].updateProvidersVotingPower(String(votingPower))
                }
            }
            
            finalityProviders.sort {
                if ($0.moniker == "Cosmostation") { return true }
                if ($1.moniker == "Cosmostation") { return false }
                if ($0.jailed && !$1.jailed) { return false }
                if (!$0.jailed && $1.jailed) { return true }
                return Double($0.votingPower)! > Double($1.votingPower)!
            }
            
        } catch {
            print("updateProvidersVotingPower Error", error)
        }
    }
    
    func btcStakingRewardAmountSum(_ denom: String) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        result = result.adding(NSDecimalNumber(string: btcStakedRewards.filter{ $0.denom == denom }.first?.amount ?? "0"))
        return result
    }
    
    func rewardOtherDenomTypeCnts() -> Int {
        var denoms = [String]()
        btcStakedRewards.filter { $0.denom != chain.stakeDenom }.forEach { reward in
            if (denoms.contains(reward.denom) == false) {
                denoms.append(reward.denom)
            }
        }
        return denoms.count
    }

}

// MARK: grpc, lcd Fetch
extension BabylonBTCFetcher {
    
    func fetchParams() async throws -> Babylon_Btcstaking_V1_Params? {
        if (getEndpointType() == .UseGRPC) {
            let req = Babylon_Btcstaking_V1_QueryParamsRequest()
            return try await Babylon_Btcstaking_V1_QueryNIOClient(channel: getClient()).params(req, callOptions: getCallOptions()).response.get().params
            
        } else {
            let url = getLcd() + "babylon/btcstaking/v1/params"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["params"]
            return response.params()
        }
    }
    
    func fetchFinalityProviders() async throws -> [Babylon_Btcstaking_V1_FinalityProviderResponse] {
        if (getEndpointType() == .UseGRPC) {
            let pagination = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
            let req = Babylon_Btcstaking_V1_QueryFinalityProvidersRequest.with { $0.pagination = pagination }
            return try await Babylon_Btcstaking_V1_QueryNIOClient(channel: getClient()).finalityProviders(req, callOptions: getCallOptions()).response.get().finalityProviders

        } else {
            let url = getLcd() + "babylon/btcstaking/v1/finality_providers?pagination.limit=300"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value
            return response.finalityProviders()
        }
    }

    func fetchStatusHeight() async throws -> String {
        if (getEndpointType() == .UseGRPC) {
            let req = Cosmos_Base_Node_V1beta1_StatusRequest()
            let height = try await Cosmos_Base_Node_V1beta1_ServiceNIOClient(channel: getClient()).status(req, callOptions: getCallOptions()).response.get().height
            return String(height)
        
        } else {
            let url = getLcd() + "cosmos/base/node/v1beta1/status"
            return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["height"].stringValue
        }
    }
    
    func fetchProvidersVotingPower(_ height: String) async throws -> [Babylon_Finality_V1_ActiveFinalityProvidersAtHeightResponse] {
        let url = getLcd() + "babylon/finality/v1/finality_providers/" + height
        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value.finalityProviderWithVotingPower()
    }
    
    func fetchBtcStakedRewards() async -> [Cosmos_Base_V1beta1_Coin] {
        do {
            if (getEndpointType() == .UseGRPC) {
                let req = Babylon_Incentive_QueryRewardGaugesRequest.with { $0.address = chain.bechAddress! }
                let rewardGauges = try await Babylon_Incentive_QueryNIOClient(channel: getClient()).rewardGauges(req, callOptions: getCallOptions()).response.get().rewardGauges
                var result = [Cosmos_Base_V1beta1_Coin]()
                                
                rewardGauges["BTC_STAKER"]?.coins.forEach({ coin in
                    if let withdrawn = rewardGauges["BTC_STAKER"]?.withdrawnCoins.filter({ $0.denom == coin.denom }).first {
                        let amount = (UInt64(coin.amount) ?? 0) - (UInt64(withdrawn.amount) ?? 0)
                        result.append(Cosmos_Base_V1beta1_Coin(coin.denom, String(amount)))
                    } else {
                        result.append(coin)
                    }
                })
                return result
                
            } else {
                let url = getLcd() + "babylon/incentive/address/" + chain.bechAddress! + "/reward_gauge"
                let rewardGauges = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["reward_gauges"]["BTC_STAKER"]
                var result = [Cosmos_Base_V1beta1_Coin]()
                
                rewardGauges["coins"].arrayValue.forEach({ coin in
                    if let withdrawn = rewardGauges["withdrawn_coins"].arrayValue.filter({ $0["denom"].stringValue == coin["denom"].stringValue }).first {
                        let amount = (UInt64(coin["amount"].stringValue) ?? 0) - (UInt64(withdrawn["amount"].stringValue) ?? 0)
                        result.append(Cosmos_Base_V1beta1_Coin(coin["denom"].stringValue, String(amount)))
                    } else {
                        result.append(Cosmos_Base_V1beta1_Coin(coin["denom"].stringValue,coin["amount"].stringValue))
                    }
                })
                return result
            }
            
        } catch {
            print("Error: \(#function)")
            return []
        }
    }
}

extension BabylonBTCFetcher {
    func fetchBtcDelegations(_ babylonAddr: String) async throws -> [JSON] {
        let limit = 60
        let url = MINTSCAN_API_URL + "v11/" + chain.apiName + "/btc/staker"
        let param = "?limit=\(limit)&staker_addr=\(babylonAddr)"
        var searchAfter = ""
        
        var delegations: [JSON] = []
        var result: [JSON] = []
        repeat {
            let pagination = "&search_after=\(searchAfter)"
            delegations = try await AF.request(url+param+pagination).serializingDecodable(JSON.self).value.arrayValue
            result.append(contentsOf: delegations)
            searchAfter = result.last?["search_after"].stringValue ?? ""
        } while !searchAfter.isEmpty && delegations.count == limit
        
        return result
    }
}

// MARK: babylon api fetch <limit> 50 reqs in 10 secs / 100 reqs in 1 min
extension BabylonBTCFetcher {
    func getBabylonApiUrl() -> String{
        if chain.isTestnet {
            return "https://staking-api.testnet.babylonlabs.io/v2/"
        } else {
            return "https://staking-api.babylonlabs.io/v2"
        }
    }
    
    
    func fetchBtcDelegations() async throws -> [JSON]? {
        if let btcPubKey = (chain as? ChainBitCoin86)?.publicKey?.toHexString() {
            let pubKey = String(btcPubKey.dropFirst(2)) //
            let url = getBabylonApiUrl() + "delegations?staker_pk_hex=" + pubKey
            return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"].array

        } else {
            return nil
        }
    }
}


extension BabylonBTCFetcher {
    func getLcd() -> String {
        let chain = chain.isTestnet ? ChainBabylon_T() : ChainBabylon()
        var url = ""
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_LCD_ENDPOINT +  " : " + chain.name) {
            url = endpoint
        } else {
            url = chain.lcdUrl
        }
        if (url.last != "/") {
            return url + "/"
        }
        return url
        
    }
    
    func getGrpc() -> (host: String, port: Int) {
        let chain = chain.isTestnet ? ChainBabylon_T() : ChainBabylon()
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_GRPC_ENDPOINT +  " : " + chain.name) {
            if (endpoint.components(separatedBy: ":").count == 2) {
                let host = endpoint.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                let port = Int(endpoint.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
                return (host, port!)
            }
        }
        return (chain.grpcHost, chain.grpcPort)
        
    }
    
    func getEndpointType() -> CosmosEndPointType? {
        let chain = chain.isTestnet ? ChainBabylon_T() : ChainBabylon()
        let endpointType = UserDefaults.standard.integer(forKey: KEY_COSMOS_ENDPOINT_TYPE +  " : " + chain.name)
        if (endpointType == CosmosEndPointType.UseGRPC.rawValue) {
            return .UseGRPC
        } else if (endpointType == CosmosEndPointType.UseLCD.rawValue) {
            return .UseLCD
        } else {
            return chain.cosmosEndPointType
        }
    }
    func getClient() -> ClientConnection {
        if (grpcConnection == nil) {
            let group = PlatformSupport.makeEventLoopGroup(loopCount: 4)
            grpcConnection = ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: getGrpc().host, port: getGrpc().port)
        }
        return grpcConnection!
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(20000))
        return callOptions
    }
}

// Delegation + FinalityProvider
struct BtcDelegation {
    var providerPk: String
    var moniker: String
    var commission: String
    var jailed: Bool
    var inceptionTime: String
    var transactionID: String
    var amount: Int
    var state: String
    var delegationUnbonding: JSON
    var delegationStaking: JSON
    
    init(_ delegation: JSON, _ provider: FinalityProvider?) {
        providerPk = delegation["finality_provider_btc_pks_hex"].array?.first?.stringValue ?? ""
        moniker = provider?.moniker ?? ""
        commission = provider?.commission ?? "0"
        jailed = provider?.jailed ?? true
        inceptionTime = delegation["delegation_staking"]["bbn_inception_time"].stringValue
        transactionID = delegation["delegation_staking"]["staking_tx_hash_hex"].stringValue
        amount = delegation["delegation_staking"]["staking_amount"].intValue
        state = delegation["state"].stringValue
        delegationUnbonding = delegation["delegation_unbonding"]
        delegationStaking = delegation["delegation_staking"]
    }
    
    mutating func updateDelegationProviderInfo(_ provider: FinalityProvider) {
        moniker = provider.moniker
        commission = provider.commission
        jailed = provider.jailed
    }
}

// FinalityProvider + votingPower
struct FinalityProvider {
    var moniker: String
    var commission: String
    var btcPk: String
    var votingPower: String
    var jailed: Bool
    
    init(_ provider: Babylon_Btcstaking_V1_FinalityProviderResponse, _ votingPower: String) {
        moniker = provider.description_p.moniker
        commission = provider.commission
        btcPk = provider.btcPk.toHexString()
        self.votingPower = votingPower
        jailed = provider.jailed
    }
    
    mutating func updateProvidersVotingPower(_ vp: String) {
        votingPower = vp
    }
}

extension JSON {
    func params() -> Babylon_Btcstaking_V1_Params {
        Babylon_Btcstaking_V1_Params.with { param in
            self["covenant_pks"].arrayValue.forEach({ pk in
                param.covenantPks.append(Data(hex: pk.stringValue))
            })
            param.covenantQuorum = self["covenant_quorum"].uInt32Value
            param.minStakingValueSat = Int64(self["min_staking_value_sat"].stringValue) ?? 0
            param.maxStakingValueSat = Int64(self["max_staking_value_sat"].stringValue) ?? 0
            param.minStakingTimeBlocks = self["min_staking_time_blocks"].uInt32Value
            param.maxStakingTimeBlocks = self["max_staking_time_blocks"].uInt32Value
            param.unbondingTimeBlocks = self["unbonding_time_blocks"].uInt32Value
        }
    }
    
    func finalityProviders() -> [Babylon_Btcstaking_V1_FinalityProviderResponse] {
        var result = [Babylon_Btcstaking_V1_FinalityProviderResponse]()
        self["finality_providers"].arrayValue.forEach { provider in
            let finalityProviderResponse = Babylon_Btcstaking_V1_FinalityProviderResponse.with {
                $0.description_p.moniker = provider["description"]["moniker"].stringValue
                $0.commission = provider["commission"].stringValue
                $0.btcPk = Data(hex: provider["btc_pk"].stringValue)
                $0.jailed = provider["jailed"].boolValue
            }
            result.append(finalityProviderResponse)
        }
        return result
    }
    
    func finalityProviderWithVotingPower() -> [Babylon_Finality_V1_ActiveFinalityProvidersAtHeightResponse] {
        var result = [Babylon_Finality_V1_ActiveFinalityProvidersAtHeightResponse]()
        
        self["finality_providers"].arrayValue.forEach { provider in
            let response = Babylon_Finality_V1_ActiveFinalityProvidersAtHeightResponse.with {
                $0.btcPkHex = provider["btc_pk_hex"].stringValue
                $0.votingPower = UInt64(provider["voting_power"].stringValue) ?? 0
            }
            result.append(response)
        }
        return result
    }
}
