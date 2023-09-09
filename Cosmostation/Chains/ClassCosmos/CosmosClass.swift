//
//  CosmosClass.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import GRPC
import NIO
import SwiftProtobuf
import Alamofire
import SwiftyJSON

class CosmosClass: BaseChain  {
    
    var stakeDenom: String!
    var supportCw20 = false
    var supportErc20 = false
    var supportNft = false
    
    var grpcHost = ""
    var grpcPort = 443
    lazy var cosmosAuth = Google_Protobuf_Any.init()
    lazy var cosmosBalances = Array<Cosmos_Base_V1beta1_Coin>()
    lazy var cosmosVestings = Array<Cosmos_Base_V1beta1_Coin>()
    lazy var cosmosDelegations = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    lazy var cosmosUnbondings = Array<Cosmos_Staking_V1beta1_UnbondingDelegation>()
    lazy var cosmosRewards = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
    
    lazy var mintscanTokens = Array<MintscanToken>()
    
    
    //For Legacy Lcd chains
    lazy var lcdNodeInfo = JSON()
    lazy var lcdAccountInfo = JSON()
    
    
    lazy var lcdBeaconTokens = Array<JSON>()
    
    
//    override func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
//        var result = NSDecimalNumber.zero
////        if (self is ChainBinanceBeacon) {
////            result = lcdBalanceValue(stakeDenom, usd)
////
////        } else {
////            result = balanceValueSum(usd).adding(vestingValueSum(usd))
////                .adding(delegationValueSum(usd)).adding(unbondingValueSum(usd)).adding(rewardValueSum(usd))
////
////            if (supportCw20) {
////                result = result.adding(allCw20Value(usd))
////            }
////        }
//        return result
//    }
    
    func fetchData() {
        if (self is ChainBinanceBeacon) {
            fetchLcdData()
        } else {
            fetchGrpcData()
        }
    }
}


//about grpc
extension CosmosClass {
    
    func fetchGrpcData() {
        let channel = getConnection()
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address! }
        if let response = try? Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosAuth = response.account
            self.fetchMoreData(channel)
            
        } else {
            try? channel.close()
            self.fetched = true
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.id, userInfo: nil)
            
        }
    }
    
    func fetchMoreData(_ channel: ClientConnection) {
        if (supportCw20) { BaseNetWork().fetchCw20Info(self) }
        let group = DispatchGroup()
    
        fetchBalance(group, channel)
        fetchDelegation(group, channel)
        fetchUnbondings(group, channel)
        fetchRewards(group, channel)
        
        group.notify(queue: .main) {
            try? channel.close()
            WUtils.onParseVestingAccount(self)
            self.fetched = true
            self.setAllValue()
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.id, userInfo: nil)
        }
    }
    
    func fetchBalance(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = address!; $0.pagination = page }
        if let response = try? Cosmos_Bank_V1beta1_QueryNIOClient(channel: channel).allBalances(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosBalances = response.balances
            group.leave()
        } else {
            group.leave()
        }
    }
    
    func fetchDelegation(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = address! }
        if let response = try? Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel).delegatorDelegations(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosDelegations = response.delegationResponses
            group.leave()
        } else {
            group.leave()
        }
    }
    
    func fetchUnbondings(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = address! }
        if let response = try? Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel).delegatorUnbondingDelegations(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosUnbondings = response.unbondingResponses
            group.leave()
        } else {
            group.leave()
        }
    }
    
    func fetchRewards(_ group: DispatchGroup, _ channel: ClientConnection) {
        group.enter()
        let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = address! }
        if let response = try? Cosmos_Distribution_V1beta1_QueryNIOClient(channel: channel).delegationTotalRewards(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosRewards = response.rewards
            group.leave()
        } else {
            group.leave()
        }
    }
    
    func fetchAllCw20Balance() {
        let channel = getConnection()
        let group = DispatchGroup()
        mintscanTokens.forEach { token in
            Task { fetchCw20Balance(group, channel, token) }
        }

        group.notify(queue: .main) {
            try? channel.close()
            self.setAllValue()
            NotificationCenter.default.post(name: Notification.Name("FetchCw20Tokens"), object: nil, userInfo: nil)
        }
    }

    func fetchCw20Balance(_ group: DispatchGroup, _ channel: ClientConnection, _ tokenInfo: MintscanToken) {
        group.enter()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = tokenInfo.address!
            $0.queryData = Cw20BalaceReq.init(address!).getEncode()
        }
        if let response = try? Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.wait() {
            let cw20balance = try? JSONDecoder().decode(Cw20BalaceRes.self, from: response.data)
            tokenInfo.setAmount(cw20balance?.balance ?? "0")
            group.leave()
        } else {
            group.leave()
        }
    }
    
    func balanceAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber(string: cosmosBalances.filter { $0.denom == denom }.first?.amount ?? "0")
    }
    
    func balanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = balanceAmount(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
            
        }
        return NSDecimalNumber.zero
    }
    
    func balanceValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        cosmosBalances.forEach { balance in
            result = result.adding(balanceValue(balance.denom, usd))
        }
        return result
    }
    
    func vestingAmount(_ denom: String) -> NSDecimalNumber  {
        return NSDecimalNumber(string: cosmosVestings.filter { $0.denom == denom }.first?.amount ?? "0")
    }
    
    func vestingValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = vestingAmount(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
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
        if let msAsset = BaseData.instance.getAsset(apiName, stakeDenom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = delegationAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
        }
        return NSDecimalNumber.zero
    }
    
    func unbondingAmountSum() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        cosmosUnbondings.forEach({ unbonding in
            for entry in unbonding.entries {
                sum = sum.adding(NSDecimalNumber(string: entry.balance))
            }
        })
        return sum
    }
    
    func unbondingValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, stakeDenom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = unbondingAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
        }
        return NSDecimalNumber.zero
    }
    
    
    func allStakingDenomAmount() -> NSDecimalNumber {
         return balanceAmount(stakeDenom).adding(vestingAmount(stakeDenom)).adding(delegationAmountSum())
            .adding(unbondingAmountSum()).adding(rewardAmountSum(stakeDenom))
    }
    
    
    func rewardAmountSum(_ denom: String) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        cosmosRewards.forEach({ reward in
            result = result.adding(NSDecimalNumber(string: reward.reward.filter{ $0.denom == denom }.first?.amount ?? "0"))
        })
        return result.multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(0))
    }
    
    func rewardValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = rewardAmountSum(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
        }
        return NSDecimalNumber.zero
    }
    
    func rewardAllCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        cosmosRewards.forEach({ reward in
            reward.reward.forEach { coin in
                let calReward = Cosmos_Base_V1beta1_Coin.with {
                    $0.denom = coin.denom;
                    $0.amount = NSDecimalNumber(string: coin.amount)
                        .multiplying(byPowerOf10: -18, withBehavior: getDivideHandler(0))
                        .stringValue
                }
                result.append(calReward)
            }
        })
        return result
    }
    
    func rewardOtherDenoms() -> Int {
        var result = Array<String>()
        rewardAllCoins().forEach { coin in
            if (!result.contains(coin.denom)) {
                result.append(coin.denom)
            }
        }
        result.removeAll { $0 == stakeDenom}
        return result.count
    }
    
    
    func rewardValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        rewardAllCoins().forEach { rewardCoin in
            if let msAsset = BaseData.instance.getAsset(apiName, rewardCoin.denom) {
                let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
                let amount = NSDecimalNumber(string: rewardCoin.amount)
                let value = msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: getDivideHandler(6))
                result = result.adding(value)
            }
        }
        return result
    }
    
    func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == stakeDenom) {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(delegationValueSum(usd)).adding(unbondingValueSum(usd))
            
        } else {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
        }
    }
    
    func cw20Value(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let tokenInfo =  mintscanTokens.filter({ $0.address == address }).first {
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: getDivideHandler(6))
        }
        return NSDecimalNumber.zero
    }
    
    func allCw20Value(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        mintscanTokens.forEach { tokenInfo in
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: getDivideHandler(6))
            result = result.adding(value)
        }
        return result
    }
    
    
    func setAllValue() {
        var result = NSDecimalNumber.zero
        if (self is ChainBinanceBeacon) {
            
        } else {
            result = balanceValueSum().adding(vestingValueSum()).adding(delegationValueSum()).adding(unbondingValueSum()).adding(rewardValueSum())
            if (supportCw20) {
                result = result.adding(allCw20Value())
            }
            self.allValue = result
        }
        //TODO USD value!!!!
    }
    
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: grpcHost, port: grpcPort)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(2000))
        return callOptions
    }
}


//about legacy lcd
extension CosmosClass {
    
    func fetchLcdData() {
        let group = DispatchGroup()
        
        if (self is ChainBinanceBeacon) {
            fetchNodeInfo(group)
            fetchAccountInfo(group, address!)
            fetchBeaconTokens(group)
            fetchBeaconMiniTokens(group)
        }
        
        group.notify(queue: .main) {
            self.fetched = true
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.id, userInfo: nil)
        }
    }
    
    func fetchNodeInfo(_ group: DispatchGroup) {
//        print("fetchNodeInfo Start ", BaseNetWork.lcdNodeInfoUrl(self))
        group.enter()
        AF.request(BaseNetWork.lcdNodeInfoUrl(self), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdNodeInfo = value
//                    print("fetchNodeInfo ", value)
                case .failure:
                    print("fetchNodeInfo error")
                }
                group.leave()
            }
    }
    
    func fetchAccountInfo(_ group: DispatchGroup, _ address: String) {
//        print("fetchAccountInfo Start ", BaseNetWork.lcdAccountInfoUrl(self, address))
        group.enter()
        AF.request(BaseNetWork.lcdAccountInfoUrl(self, address), method: .get)
            .responseDecodable(of: JSON.self) { response in
                switch response.result {
                case .success(let value):
                    self.lcdAccountInfo = value
//                    print("fetchAccountInfo ", value)
                case .failure:
                    print("fetchAccountInfo error")
                }
                group.leave()
            }
    }
    
    func fetchBeaconTokens(_ group: DispatchGroup) {
        group.enter()
        AF.request(BaseNetWork.lcdBeaconTokenUrl(), method: .get, parameters: ["limit":"1000"])
            .responseDecodable(of: [JSON].self) { response in
                switch response.result {
                case .success(let values):
                    values.forEach { value in
                        self.lcdBeaconTokens.append(value)
                    }
                case .failure:
                    print("fetchBeaconTokens error")
                }
                group.leave()
            }
    }
    
    func fetchBeaconMiniTokens(_ group: DispatchGroup) {
        group.enter()
        AF.request(BaseNetWork.lcdBeaconMiniTokenUrl(), method: .get, parameters: ["limit":"1000"])
            .responseDecodable(of: [JSON].self) { response in
                switch response.result {
                case .success(let values):
                    values.forEach { value in
                        self.lcdBeaconTokens.append(value)
                    }
                case .failure:
                    print("fetchBeaconMiniTokens error")
                }
                group.leave()
            }
    }
    
    
    func lcdBalanceAmount(_ denom: String) -> NSDecimalNumber {
        if let balance = lcdAccountInfo["balances"].array?.filter({ $0["symbol"].string == denom }).first {
            return NSDecimalNumber.init(string: balance["free"].string ?? "0")
        }
        return NSDecimalNumber.zero
    }
    
    func lcdBalanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == stakeDenom) {
            let amount = lcdBalanceAmount(denom)
            let msPrice = BaseData.instance.getPrice(ChainBinanceBeacon.BNB_GECKO_ID, usd)
            return msPrice.multiplying(by: amount, withBehavior: getDivideHandler(6))
        }
        return NSDecimalNumber.zero
    }
    
    func lcdBalanceValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        lcdAccountInfo["balances"].array?.forEach({ balance in
            result = result.adding(lcdBalanceValue(balance["denom"].stringValue, usd))
        })
        return result
    }
}


func ALLCOSMOSCLASS() -> [CosmosClass] {
    var result = [CosmosClass]()
    result.removeAll()
    result.append(ChainCosmos())
    result.append(ChainAkash())
    result.append(ChainAssetMantle())
    result.append(ChainAxelar())
    result.append(ChainBinanceBeacon())
    result.append(ChainCanto())
    result.append(ChainEvmos())
    result.append(ChainInjective())
    result.append(ChainJuno())
    result.append(ChainKava459())
    result.append(ChainKava60())
    result.append(ChainKava118())
    result.append(ChainKi())
    result.append(ChainLum880())
    result.append(ChainLum118())
    result.append(ChainOsmosis())
    result.append(ChainPersistence118())
    result.append(ChainPersistence750())
    result.append(ChainSommelier())
    result.append(ChainStargaze())
    result.append(ChainUmee())
    return result
}

let DEFUAL_DISPALY_COSMOS = ["cosmos118", "lum118", "axelar118", "kava459", "stargaze118"]
