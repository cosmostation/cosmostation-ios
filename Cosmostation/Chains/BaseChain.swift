//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO


class BaseChain {
    var name: String!
    var id: String!
    var isDefault = true
    var accountKeyType: AccountKeyType!
    
    var privateKey: Data?
    var publicKey: Data?
    var address: String?
    
    var accountPrefix: String?
    
    var grpcHost = ""
    var grpcPort = 443
    var cosmosBalances = [Cosmos_Base_V1beta1_Coin]()
    var cosmosDelegations = [Cosmos_Staking_V1beta1_DelegationResponse]()
    var cosmosUnbondings = [Cosmos_Staking_V1beta1_UnbondingDelegation]()
    var cosmosRewards = [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]()
    
    
    func getHDPath(_ lastPath: String) -> String {
        return accountKeyType.hdPath.replacingOccurrences(of: "X", with: lastPath)
    }
    
    func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        address = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, accountPrefix)
    }
    
    func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        address = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, accountPrefix)
    }
    
    func fetchData() {
        print("fetchData ", Date().timeIntervalSince1970, " ",  self.address)
        let group = DispatchGroup()
        let channel = getConnection()

        fetchBalance(group, channel)
        fetchDelegation(group, channel)
        fetchUnbondings(group, channel)
        fetchRewards(group, channel)

        group.notify(queue: .main) {
//            try channel.close().wait()
            try? channel.close().wait()

//            print("notify cosmosBalances", self.address, " ", self.cosmosBalances)chain
//            print("notify cosmosDelegations", self.address, " ", self.cosmosDelegations)
//
//            print("notify ", String(describing: self))
//            let value = ["chain": String(describing: self)]
//            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: nil, userInfo: value)
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: String(describing: self), userInfo: nil)
        }
        
    }
    
    func fetchBalance(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = address!; $0.pagination = page }
        if let response = try? Cosmos_Bank_V1beta1_QueryNIOClient(channel: channel).allBalances(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosBalances = response.balances
            group.leave()
        }
    }
    
    func fetchDelegation(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = address! }
        if let response = try? Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel).delegatorDelegations(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosDelegations = response.delegationResponses
            group.leave()
        }
    }
    
    func fetchUnbondings(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = address! }
        if let response = try? Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel).delegatorUnbondingDelegations(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosUnbondings = response.unbondingResponses
            group.leave()
        }
    }
    
    func fetchRewards(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = address! }
        if let response = try? Cosmos_Distribution_V1beta1_QueryNIOClient(channel: channel).delegationTotalRewards(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosRewards = response.rewards
            group.leave()
        }
    }
    
    func hasValue() -> Bool {
        if (cosmosBalances.isEmpty || cosmosBalances.isEmpty || cosmosUnbondings.isEmpty || cosmosRewards.isEmpty) {
            return false
        }
        return true
    }
    
    
    func getConnection() -> ClientConnection {
//        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//        return ClientConnection.secure(group: group).connect(host: grpcHost, port: grpcPort)
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: grpcHost, port: grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(8000))
        return callOptions
    }
}



struct AccountKeyType {
    var pubkeyType: PubKeyType!
    var hdPath: String!
    
    init(_ pubkeyType: PubKeyType!, _ hdPath: String!) {
        self.pubkeyType = pubkeyType
        self.hdPath = hdPath
    }
}

enum PubKeyType: Int {
    case ETH_Keccak256 = 0
    case COSMOS_Secp256k1 = 1
    case SUI_Ed25519 = 2
    case unknown = 99
}
