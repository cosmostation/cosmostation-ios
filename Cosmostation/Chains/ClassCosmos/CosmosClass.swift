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
import web3swift

class CosmosClass: BaseChain {
    
    var stakeDenom: String!
    var supportCw20 = false
    var supportErc20 = false
    var supportNft = false
    var supportStaking = true
    
    var evmCompatible = false
    var evmAddress: String?
    
    var grpcHost = ""
    var grpcPort = 443
    
    lazy var rpcURL = ""
    
    lazy var rewardAddress = ""
    lazy var cosmosAuth = Google_Protobuf_Any.init()
    lazy var cosmosValidators = Array<Cosmos_Staking_V1beta1_Validator>()
    lazy var cosmosBalances = Array<Cosmos_Base_V1beta1_Coin>()
    lazy var cosmosVestings = Array<Cosmos_Base_V1beta1_Coin>()
    lazy var cosmosDelegations = Array<Cosmos_Staking_V1beta1_DelegationResponse>()
    lazy var cosmosUnbondings = Array<Cosmos_Staking_V1beta1_UnbondingDelegation>()
    lazy var cosmosRewards = Array<Cosmos_Distribution_V1beta1_DelegationDelegatorReward>()
    
    lazy var mintscanTokens = Array<MintscanToken>()
    lazy var mintscanChainParam = JSON()
    
    func fetchData(_ id: Int64) {
        Task {
            if let rawParam = try? await self.fetchChainParam() {
                mintscanChainParam = rawParam
            }
            if (supportCw20) {
                if let cw20s = try? await self.fetchCw20Info() {
                    mintscanTokens = cw20s.assets!
                }
            }
            if (supportErc20) {
                if let erc20s = try? await self.fetchErc20Info() {
                    mintscanTokens = erc20s.assets!
                }
            }
        }
        fetchGrpcData(id)
    }
    
    func fetchPropertyData(_ channel: ClientConnection, _ id: Int64) {
        let group = DispatchGroup()
    
        fetchBalance(group, channel)
        if (self.supportStaking) {
            fetchDelegation(group, channel)
            fetchUnbondings(group, channel)
            fetchRewards(group, channel)
        }
        
        group.notify(queue: .main) {
            try? channel.close()
            WUtils.onParseVestingAccount(self)
            self.fetched = true
            self.allCoinValue = self.allCoinValue()
            self.allCoinUSDValue = self.allCoinValue(true)
            
            BaseData.instance.updateRefAddressesMain(
                RefAddress(id, self.tag, self.address!,
                           self.allStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                           nil, self.cosmosBalances.count))
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
        }
    }
    
    func fetchStakeData() {
        if (cosmosValidators.count > 0) { return }
        Task {
            let channel = getConnection()
            if let rewardaddr = try? await fetchRewardAddress(channel),
               let bonded = try? await fetchBondedValidator(channel),
               let unbonding = try? await fetchUnbondingValidator(channel),
               let unbonded = try? await fetchUnbondedValidator(channel) {
                
                rewardAddress = rewardaddr ?? ""
                
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
            }
            DispatchQueue.main.async {
                try? channel.close()
                NotificationCenter.default.post(name: Notification.Name("FetchStakeData"), object: self.tag, userInfo: nil)
            }
        }
    }
    
    func allStakingDenomAmount() -> NSDecimalNumber {
         return balanceAmount(stakeDenom).adding(vestingAmount(stakeDenom)).adding(delegationAmountSum())
            .adding(unbondingAmountSum()).adding(rewardAmountSum(stakeDenom))
    }
    
    func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == stakeDenom) {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
                .adding(delegationValueSum(usd)).adding(unbondingValueSum(usd))
            
        } else {
            return balanceValue(denom, usd).adding(vestingValue(denom, usd)).adding(rewardValue(denom, usd))
        }
    }
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(vestingValueSum(usd)).adding(delegationValueSum(usd)).adding(unbondingValueSum(usd)).adding(rewardValueSum(usd))
    }
    
    func monikerImg(_ opAddress: String) -> URL {
        return URL(string: ResourceBase + apiName + "/moniker/" + opAddress + ".png") ?? URL(string: "")!
    }
    
    
    func getGrpc() -> (host: String, port: Int) {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_GRPC_ENDPOINT +  " : " + self.name) {
            if (endpoint.components(separatedBy: ":").count == 2) {
                let host = endpoint.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
                let port = Int(endpoint.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
                return (host, port!)
            }
        }
        return (grpcHost, grpcPort)
    }
}

//gas fee
extension CosmosClass {
    
    func getChainParam() -> JSON {
        return mintscanChainParam["params"]["chainlist_params"]
    }
    
    func isGasSimulable() -> Bool {
        return getChainParam()["fee"]["isSimulable"].bool ?? true
    }
    
    func feeThreshold() -> String? {
        return nil
    }
    
    func gasMultiply() -> Double {
        if let mutiply = getChainParam()["fee"]["simul_gas_multiply"].double {
            return mutiply
        }
        return 1.2
    }
    
    func getFeeInfos() -> [FeeInfo] {
        var result = [FeeInfo]()
        getChainParam()["fee"]["rate"].arrayValue.forEach { rate in
            result.append(FeeInfo.init(rate.stringValue))
        }
        if (result.count == 1) {
            result[0].title = NSLocalizedString("str_fixed", comment: "")
        } else if (result.count == 2) {
            result[1].title = NSLocalizedString("str_average", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
            }
        } else if (result.count == 3) {
            result[2].title = NSLocalizedString("str_average", comment: "")
            result[1].title = NSLocalizedString("str_low", comment: "")
            if (result[0].FeeDatas[0].gasRate == NSDecimalNumber.zero) {
                result[0].title = NSLocalizedString("str_zero", comment: "")
            } else {
                result[0].title = NSLocalizedString("str_tiny", comment: "")
            }
        }
        return result
    }
    
    func getFeeBasePosition() -> Int {
        return getChainParam()["fee"]["base"].intValue
    }
    
    //get chainlist suggest fees array
    func getDefaultFeeCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        let gasAmount = NSDecimalNumber.init(string: BASE_GAS_AMOUNT)
        let feeDatas = getFeeInfos()[getFeeBasePosition()].FeeDatas
        feeDatas.forEach { feeData in
            let amount = (feeData.gasRate)!.multiplying(by: gasAmount, withBehavior: handler0Up)
            result.append(Cosmos_Base_V1beta1_Coin.with {  $0.denom = feeData.denom!; $0.amount = amount.stringValue })
        }
        return result
    }
    
    //get first payable fee with this account
    func getInitPayableFee() -> Cosmos_Tx_V1beta1_Fee? {
        var feeCoin: Cosmos_Base_V1beta1_Coin?
        for i in 0..<getDefaultFeeCoins().count {
            let minFee = getDefaultFeeCoins()[i]
            if (balanceAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                feeCoin = Cosmos_Base_V1beta1_Coin.with {  $0.denom = minFee.denom; $0.amount = minFee.amount }
                break
            }
        }
        if (feeCoin != nil) {
            return Cosmos_Tx_V1beta1_Fee.with {
                $0.gasLimit = UInt64(BASE_GAS_AMOUNT)!
                $0.amount = [feeCoin!]
            }
        }
        return nil
    }
    
    // check account payable with lowest fee
    func isTxFeePayable() -> Bool {
        var result = false
        getDefaultFeeCoins().forEach { minFee in
            if (balanceAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                result = true
                return
            }
        }
        return result
    }
    
    //get user selected fee
    func getUserSelectedFee(_ position: Int, _ denom: String) -> Cosmos_Tx_V1beta1_Fee {
        let gasAmount = NSDecimalNumber.init(string: BASE_GAS_AMOUNT)
        let feeDatas = getFeeInfos()[position].FeeDatas
        let rate = feeDatas.filter { $0.denom == denom }.first!.gasRate
        let coinAmount = rate!.multiplying(by: gasAmount, withBehavior: handler0Up)
        return Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = UInt64(BASE_GAS_AMOUNT)!
            $0.amount = [Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = coinAmount.stringValue }]
        }
    }
    
}


//about mintscan api
extension CosmosClass {
    
    func fetchChainParam() async throws -> JSON {
        print("fetchChainParam ", BaseNetWork.msChainParam(self))
        return try await AF.request(BaseNetWork.msChainParam(self), method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchCw20Info() async throws -> MintscanTokens {
//        print("fetchCw20Info ", BaseNetWork.msCw20InfoUrl(self))
        return try await AF.request(BaseNetWork.msCw20InfoUrl(self), method: .get).serializingDecodable(MintscanTokens.self).value
    }
    
    func fetchErc20Info() async throws -> MintscanTokens {
        print("fetchErc20Info ", BaseNetWork.msErc20InfoUrl(self))
        return try await AF.request(BaseNetWork.msErc20InfoUrl(self), method: .get).serializingDecodable(MintscanTokens.self).value
    }
    
}


//about grpc
extension CosmosClass {
    
    func fetchBondedValidator(_ channel: ClientConnection) async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
        return try? await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel).validators(req).response.get().validators
    }
    
    func fetchUnbondedValidator(_ channel: ClientConnection) async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDED" }
        return try? await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel).validators(req).response.get().validators
    }
    
    func fetchUnbondingValidator(_ channel: ClientConnection) async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDING" }
        return try? await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel).validators(req).response.get().validators
    }
    
    func fetchRewardAddress(_ channel: ClientConnection) async throws -> String? {
        let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with { $0.delegatorAddress = address! }
        return try? await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: channel).delegatorWithdrawAddress(req).response.get().withdrawAddress.replacingOccurrences(of: "\"", with: "")
    }
    
    func fetchGrpcData(_ id: Int64) {
        let channel = getConnection()
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = address! }
        if let response = try? Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel).account(req, callOptions: getCallOptions()).response.wait() {
            self.cosmosAuth = response.account
            self.fetchPropertyData(channel, id)
            
        } else {
            try? channel.close()
            self.fetched = true
            BaseData.instance.updateRefAddressesMain(
                RefAddress(id, self.tag, self.address!, 
                           nil, nil, nil, nil))
            NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
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
            self.cosmosDelegations.removeAll()
            response.delegationResponses.forEach { delegation in
                if (delegation.balance.amount != "0") {
                    self.cosmosDelegations.append(delegation)
                }
            }
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
    
    func fetchAllCw20Balance(_ id: Int64) {
        let channel = getConnection()
        let group = DispatchGroup()
        mintscanTokens.forEach { token in
            fetchCw20Balance(group, channel, token)
        }

        group.notify(queue: .main) {
            try? channel.close()
            self.allTokenValue = self.allTokenValue()
            self.allTokenUSDValue = self.allTokenValue(true)
            
            BaseData.instance.updateRefAddressesToken(
                RefAddress(id, self.tag, self.address!,
                           nil, nil, self.allTokenUSDValue.stringValue, nil))
            NotificationCenter.default.post(name: Notification.Name("FetchTokens"), object: nil, userInfo: nil)
        }
    }

    func fetchCw20Balance(_ group: DispatchGroup, _ channel: ClientConnection, _ tokenInfo: MintscanToken) {
        group.enter()
        DispatchQueue.global().async {
            let query: JSON = ["balance" : ["address" : self.address!]]
            let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
            let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
                $0.address = tokenInfo.address!
                $0.queryData = Data(base64Encoded: queryBase64)!
            }
            if let response = try? Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: self.getCallOptions()).response.wait() {
                let cw20balance = try? JSONDecoder().decode(JSON.self, from: response.data)
                tokenInfo.setAmount(cw20balance?["balance"].string ?? "0")
                group.leave()
            } else {
                group.leave()
            }
        }
    }
    
    func fetchAllErc20Balance(_ id: Int64) {
        let group = DispatchGroup()
        guard let url = URL(string: rpcURL) else { return }
        guard let web3 = try? Web3.new(url) else { return }
        var accountEthAddr: EthereumAddress!
        if (address!.starts(with: "0x")) {
            accountEthAddr = EthereumAddress.init(address!)
        } else {
            accountEthAddr = EthereumAddress.init(KeyFac.convertBech32ToEvm(address!))
        }
        
        mintscanTokens.forEach { token in
            fetchErc20Balance(group, web3, accountEthAddr, token)
        }
        
        group.notify(queue: .main) {
            self.allTokenValue = self.allTokenValue()
            self.allTokenUSDValue = self.allTokenValue(true)
            
            BaseData.instance.updateRefAddressesToken(
                RefAddress(id, self.tag, self.address!,
                           nil, nil, self.allTokenUSDValue.stringValue, nil))
            NotificationCenter.default.post(name: Notification.Name("FetchTokens"), object: nil, userInfo: nil)
        }
    }
    
    func fetchErc20Balance(_ group: DispatchGroup, _ web3: web3?, _ accountEthAddr: EthereumAddress, _ tokenInfo: MintscanToken) {
        group.enter()
        DispatchQueue.global().async {
            let contractAddress = EthereumAddress.init(tokenInfo.address!)
            let erc20token = ERC20(web3: web3!, provider: web3!.provider, address: contractAddress!)
            if let erc20Balance = try? erc20token.getBalance(account: accountEthAddr) {
                tokenInfo.setAmount(String(erc20Balance))
                group.leave()
            } else {
                group.leave()
            }
        }
    }
    
    func balanceAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber(string: cosmosBalances.filter { $0.denom == denom }.first?.amount ?? "0")
    }
    
    func balanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = balanceAmount(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
            
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
        if let msAsset = BaseData.instance.getAsset(apiName, stakeDenom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = delegationAmountSum()
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
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
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    
    func rewardAmountSum(_ denom: String) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        cosmosRewards.forEach({ reward in
            result = result.adding(NSDecimalNumber(string: reward.reward.filter{ $0.denom == denom }.first?.amount ?? "0"))
        })
        return result.multiplying(byPowerOf10: -18, withBehavior: handler0Down)
    }
    
    func rewardValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            let amount = rewardAmountSum(denom)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func rewardAllCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        cosmosRewards.forEach({ reward in
            reward.reward.forEach { coin in
                let calAmount = NSDecimalNumber(string: coin.amount) .multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                if (calAmount != NSDecimalNumber.zero) {
                    let calReward = Cosmos_Base_V1beta1_Coin.with {
                        $0.denom = coin.denom;
                        $0.amount = calAmount.stringValue
                    }
                    result.append(calReward)
                }
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
        result.removeAll { $0 == stakeDenom }
        return result.count
    }
    
    
    func rewardValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        rewardAllCoins().forEach { rewardCoin in
            if let msAsset = BaseData.instance.getAsset(apiName, rewardCoin.denom) {
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
        cosmosRewards.forEach { reward in
            for i in 0..<reward.reward.count {
                let rewardAmount = NSDecimalNumber(string: reward.reward[i].amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                if (rewardAmount.compare(NSDecimalNumber.one).rawValue > 0) {
                    result.append(reward)
                    break
                }
            }
            return
        }
        return result
    }
    
    
    func tokenValue(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let tokenInfo = mintscanTokens.filter({ $0.address == address }).first {
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        mintscanTokens.forEach { tokenInfo in
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
            result = result.adding(value)
        }
        return result
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: getGrpc().host, port: getGrpc().port)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(3000))
        return callOptions
    }
}


func ALLCOSMOSCLASS() -> [CosmosClass] {
    var result = [CosmosClass]()
    result.removeAll()
    result.append(ChainCosmos())
    result.append(ChainAkash())
    result.append(ChainArchway())
    result.append(ChainAssetMantle())
    result.append(ChainAxelar())
    result.append(ChainBand())
    result.append(ChainBitcana())
    result.append(ChainBitsong())
    result.append(ChainCanto())
    result.append(ChainCelestia())
    result.append(ChainChihuahua())
    result.append(ChainComdex())
    result.append(ChainCoreum())
    result.append(ChainCrescent())
    result.append(ChainCryptoorg())
    result.append(ChainCudos())
    result.append(ChainDesmos())
    result.append(ChainDydx())
    result.append(ChainEmoney())
    result.append(ChainEvmos())
    result.append(ChainFetchAi())
    result.append(ChainGravityBridge())
    result.append(ChainHumans())
    result.append(ChainInjective())
    result.append(ChainIxo())
    result.append(ChainJuno())
    result.append(ChainKava459())
    result.append(ChainKava60())
    result.append(ChainKava118())
    result.append(ChainKi())
    result.append(ChainKyve())
    result.append(ChainLike())
    result.append(ChainLum880())
    result.append(ChainLum118())
    result.append(ChainMars())
    result.append(ChainMedibloc())
    result.append(ChainNeutron())
    result.append(ChainNoble())
    result.append(ChainNyx())
    result.append(ChainOmniflix())
    result.append(ChainOnomy())
    result.append(ChainOsmosis())
    result.append(ChainPassage())
    result.append(ChainPersistence118())
    result.append(ChainPersistence750())
    result.append(ChainProvenance())
    result.append(ChainQuasar())
    result.append(ChainQuicksilver())
    result.append(ChainRegen())
    result.append(ChainRizon())
    result.append(ChainSecret118())
    result.append(ChainSecre529())
    result.append(ChainSei())
    result.append(ChainSentinel())
    result.append(ChainShentu())
    result.append(ChainSommelier())
    result.append(ChainStafi())
    result.append(ChainStargaze())
    result.append(ChainStarname())
    result.append(ChainStride())
    result.append(ChainTerra())
    result.append(ChainTeritori())
    result.append(ChainUmee())
    result.append(ChainXpla())
    result.append(ChainXplaKeccak256())
    
    result.append(ChainBinanceBeacon())
    result.append(ChainOkt60Keccak())
    result.append(ChainOkt996Secp())
    result.append(ChainOkt996Keccak())
    
        
    
    result.forEach { chain in
        if let chainId = BaseData.instance.mintscanChains?["chains"].arrayValue.filter({ $0["chain"].stringValue == chain.apiName }).first?["chain_id"].stringValue {
            chain.chainId = chainId
        }
    }
    return result
}

let DEFUAL_DISPALY_COSMOS = ["cosmos118", "neutron118", "kava459", "osmosis118", "akash118", "stargaze118", "crypto-org394", "gravity-bridge118", "passage118"]

extension Cosmos_Base_V1beta1_Coin {
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: amount)
    }
    
    init (_ denom: String, _ amount: String) {
        self.denom = denom
        self.amount = amount
    }
    
    init (_ denom: String, _ amount: NSDecimalNumber) {
        self.denom = denom
        self.amount = amount.stringValue
    }
}
