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
    var finalityProviders = [FinalityProvider]()
    var btcStakedReward: NSDecimalNumber = .zero
    
    var grpcConnection: ClientConnection?

    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    
    func fetchBtcStakingData() async -> Bool {
        btcDelegations = []
        btcStakedReward = .zero
        
        do {
            if let delegations = try await fetchBtcDelegations() {
                
                btcStakedReward = try await fetchBtcStakedRewards()
                
                await delegations.concurrentForEach { delegation in
                    if let pk = delegation["finality_provider_btc_pks_hex"].array?.first?.stringValue,
                       let version = delegation["params_version"].int {
                        do {
                            let provider = try await self.fetchFinalityProvider(pk)
                            self.btcDelegations.append(BtcDelegation.init(delegation, provider))
                        } catch {
                            print(error)
                        }
                    }
                }
                
                btcDelegations.sort {
                    if let a = WUtils.timeStringToDate($0.inceptionTime),
                       let b = WUtils.timeStringToDate($1.inceptionTime) {
                        return a > b
                    } else {
                        return true
                    }
                }
                
            } else {
                return false
            }
            return true

        } catch {
            print("fetchBtcStakingData error \(error)")
            return false
        }
    }
    
    func fetchFinalityProvidersInfo() async -> Bool {
        finalityProviders = []
        do {
            try await fetchFinalityProviders().concurrentForEach { provider in
                let btcPk = provider.btcPk.toHexString()
                if let votingPower = try? await self.fetchProviderVotingPower(btcPk) {
                    self.finalityProviders.append(FinalityProvider(provider, votingPower))
                }
            }
            finalityProviders.sort {
                if ($0.moniker == "Cosmostation") { return true }
                if ($1.moniker == "Cosmostation") { return false }
                if ($0.jailed && !$1.jailed) { return false }
                if (!$0.jailed && $1.jailed) { return true }
                return Double($0.votingPower)! > Double($1.votingPower)!
            }

            return true
            
        } catch {
            print("fetchFinalityProvidersInfo error \(error)")
            return false
        }
    }
}

// MARK: grpc, lcd Fetch
extension BabylonBTCFetcher {
    
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
    
    func fetchFinalityProvider(_ providerBtcPk: String) async throws -> Babylon_Btcstaking_V1_FinalityProviderResponse {
        if (getEndpointType() == .UseGRPC) {
            let req = Babylon_Btcstaking_V1_QueryFinalityProviderRequest.with { $0.fpBtcPkHex = providerBtcPk }
            return try await Babylon_Btcstaking_V1_QueryNIOClient(channel: getClient()).finalityProvider(req, callOptions: getCallOptions()).response.get().finalityProvider
        } else {
            let url = getLcd() + "babylon/btcstaking/v1/finality_providers/" + providerBtcPk + "/finality_provider"
            let response = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["finality_provider"]
            return response.finalityProvider()
        }
    }
    
    func fetchProviderVotingPower(_ providerBtcPk: String) async throws -> String {
        
        if (getEndpointType() == .UseGRPC) {
            let req = Babylon_Finality_V1_QueryFinalityProviderCurrentPowerRequest.with { $0.fpBtcPkHex = providerBtcPk }
            let power = try await Babylon_Finality_V1_QueryNIOClient(channel: getClient()).finalityProviderCurrentPower(req, callOptions: getCallOptions()).response.get().votingPower
            return String(power)

        } else {
            let url = getLcd() + "babylon/finality/v1/finality_providers/" + providerBtcPk + "/power"
            return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["voting_power"].stringValue
        }
    }

    
    func fetchBtcStakedRewards() async throws -> NSDecimalNumber {
        if (getEndpointType() == .UseGRPC) {
            let req = Babylon_Incentive_QueryRewardGaugesRequest.with { $0.address = chain.bechAddress! }
            let rewardGauges = try await Babylon_Incentive_QueryNIOClient(channel: getClient()).rewardGauges(req, callOptions: getCallOptions()).response.get().rewardGauges
            if let coins = rewardGauges["btc_delegation"]?.coins.filter({ $0.denom == chain.stakeDenom }),
               let withdrawnCoins = rewardGauges["btc_delegation"]?.withdrawnCoins.filter({ $0.denom == chain.stakeDenom }) {
                
                let coin = coins.map({ Int($0.amount) ?? 0 }).reduce(0, +)
                let withdrawnCoin = withdrawnCoins.map({ Int($0.amount) ?? 0 }).reduce(0, +)
                return NSDecimalNumber(integerLiteral: coin).subtracting(NSDecimalNumber(integerLiteral: withdrawnCoin))
                
            } else if let coins = rewardGauges["btc_delegation"]?.coins.filter({ $0.denom == chain.stakeDenom }) {
                let coin = coins.map({ Int($0.amount) ?? 0 }).reduce(0, +)
                return NSDecimalNumber(integerLiteral: coin)

            } else {
                return .zero
            }
            
        } else {
            let url = getLcd() + "babylon/incentive/address/" + chain.bechAddress! + "/reward_gauge"
            let rewardGauges = try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["reward_gauges"]["btc_delegation"]
            if let coins = rewardGauges["coins"].array?.filter({ $0["denom"].stringValue == chain.stakeDenom }),
               let withdrawnCoins = rewardGauges["withdrawn_coins"].array?.filter({ $0["denom"].stringValue == chain.stakeDenom }) {
                
                let coin = coins.map({ Int($0["amount"].stringValue) ?? 0 }).reduce(0, +)
                let withdrawnCoin = withdrawnCoins.map({ Int($0["amount"].stringValue) ?? 0 }).reduce(0, +)
                return NSDecimalNumber(integerLiteral: coin).subtracting(NSDecimalNumber(integerLiteral: withdrawnCoin))
                
            } else if let coins = rewardGauges["coins"].array?.filter({ $0["denom"].stringValue == chain.stakeDenom }) {
                let coin = coins.map({ Int($0["amount"].stringValue) ?? 0 }).reduce(0, +)
                return NSDecimalNumber(integerLiteral: coin)

            } else {
                return .zero
            }
        }
    }
}

// MARK: babylon api fetch <limit> 50 reqs in 10 secs / 100 reqs in 1 min
extension BabylonBTCFetcher {
    
    func fetchBtcDelegations() async throws -> [JSON]? {
        print(#function)
        if let btcPubKey = (chain as? ChainBabylon)?.btcPubKey {
            
            let pubKey = String(btcPubKey.dropFirst(2))
            var url = ""
            if chain.isTestnet {
                url = "https://staking-api.testnet.babylonlabs.io/v2/delegations?staker_pk_hex=" + pubKey
            } else {
                url = "https://staking-api.babylonlabs.io/v2/delegations?staker_pk_hex=" + pubKey
            }
            
            return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"].array
            
        } else {
            return nil
        }
    }
    
    func fetchNetworkInfo() async throws -> [JSON]? {
        print(#function)
        var url = ""
        if chain.isTestnet {
            url = "https://staking-api.testnet.babylonlabs.io/v2/network-info"
        } else {
            url = "https://staking-api.babylonlabs.io/v2/network-info"
        }

        return try await AF.request(url, method: .get).serializingDecodable(JSON.self).value["data"]["params"]["bbn"].array
    }
}


extension BabylonBTCFetcher {
    func getLcd() -> String {
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
        let endpointType = UserDefaults.standard.integer(forKey: KEY_COSMOS_ENDPOINT_TYPE +  " : " + chain.name)
        if (endpointType == CosmosEndPointType.UseGRPC.rawValue) {
            return .UseGRPC
        } else if (endpointType == CosmosEndPointType.UseLCD.rawValue) {
            return .UseLCD
        } else if (endpointType == CosmosEndPointType.UseRPC.rawValue) {
            return .UseRPC
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
    
    init(_ delegation: JSON, _ provider: Babylon_Btcstaking_V1_FinalityProviderResponse) {
        providerPk = delegation["finality_provider_btc_pks_hex"].array?.first?.stringValue ?? ""
        moniker = provider.description_p.moniker
        commission = provider.commission
        jailed = provider.jailed
        inceptionTime = delegation["delegation_staking"]["bbn_inception_time"].stringValue
        transactionID = delegation["delegation_staking"]["staking_tx_hash_hex"].stringValue
        amount = delegation["delegation_staking"]["staking_amount"].intValue
        state = delegation["state"].stringValue
        delegationUnbonding = delegation["delegation_unbonding"]
        delegationStaking = delegation["delegation_staking"]
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
}

extension JSON {
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
    
    func finalityProvider() -> Babylon_Btcstaking_V1_FinalityProviderResponse {
        let result = Babylon_Btcstaking_V1_FinalityProviderResponse.with {
            $0.description_p.moniker = self["description"]["moniker"].stringValue
            $0.commission = self["commission"].stringValue
            $0.btcPk = Data(hex: self["btc_pk"].stringValue)
            $0.jailed = self["jailed"].boolValue
        }
        return result
    }

}
