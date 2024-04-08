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
    var bechAccountPrefix: String?
    var bechAddress = ""
    var validatorPrefix: String?
    var bechOpAddress: String?
    var evmAddress = ""
    
    var supportCw20 = false
    var supportCw721 = false
    var supportStaking = true
    
    var grpcHost = ""
    var grpcPort = 443
    
    
    var cosmosAuth: Google_Protobuf_Any?
    var cosmosBalances: [Cosmos_Base_V1beta1_Coin]?
    var cosmosVestings = [Cosmos_Base_V1beta1_Coin]()
    var cosmosDelegations = [Cosmos_Staking_V1beta1_DelegationResponse]()
    var cosmosUnbondings: [Cosmos_Staking_V1beta1_UnbondingDelegation]?
    var cosmosRewards: [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]?
    var cosmosCommissions =  [Cosmos_Base_V1beta1_Coin]()
    var rewardAddress:  String?
    var cosmosValidators = [Cosmos_Staking_V1beta1_Validator]()
    
    lazy var mintscanCw20Tokens = [MintscanToken]()
    lazy var mintscanCw721List = [JSON]()
    lazy var cw721Models = [Cw721Model]()
    var cw721Fetched = false
    
    //get bech style info from seed
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
    //get bech style info from privatekey
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
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
        
        Task {
            do {
                let channel = getConnection()
                if let cw20Tokens = try await fetchCw20Info(),
                   let cw721List = try await fetchCw721Info(),
                   let auth = try await fetchAuth(channel),
                   let balance = try await fetchBalance(channel),
                   let delegations = try? await fetchDelegation(channel),
                   let unbonding = try? await fetchUnbondings(channel),
                   let rewards = try? await fetchRewards(channel),
                   let commission = try? await fetchCommission(channel),
                   let rewardaddr = try? await fetchRewardAddress(channel) {
                    self.mintscanCw20Tokens = cw20Tokens
                    self.mintscanCw721List = cw721List
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
                }
                
                DispatchQueue.main.async {
                    WUtils.onParseVestingAccount(self)
                    self.fetchState = .Success
                    self.allCoinValue = self.allCoinValue()
                    self.allCoinUSDValue = self.allCoinValue(true)
//                    print("Done ", self.tag, "  ", self.allCoinValue)
                    if (self.supportCw20) { self.fetchAllCw20Balance(id) }
                    
                    BaseData.instance.updateRefAddressesCoinValue(
                        RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                                   self.allStakingDenomAmount().stringValue, self.allCoinUSDValue.stringValue,
                                   nil, self.cosmosBalances?.filter({ BaseData.instance.getAsset(self.apiName, $0.denom) != nil }).count))
                    NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
                    try? channel.close()
                }
                
            } catch {
//                print("error ",tag, "  ", error)
                DispatchQueue.main.async {
                    if let errorMessage = (error as? GRPCStatus)?.message,
                       errorMessage.contains(self.bechAddress) == true,
                       errorMessage.contains("not found") == true {
                        self.fetchState = .Success
                        BaseData.instance.updateRefAddressesCoinValue(
                            RefAddress(id, self.tag, self.bechAddress, self.evmAddress))
                    } else {
                        self.fetchState = .Fail
                    }
                    NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
                }
            }
        }
    }
    
    //fetch only balance for add account check
    override func fetchPreCreate() {
        self.cosmosBalances = [Cosmos_Base_V1beta1_Coin]()
        Task {
            let channel = getConnection()
            if let balance = try? await fetchBalance(channel) {
                self.cosmosBalances = balance
            }
            DispatchQueue.main.async {
                self.fetchState = .Success
                NotificationCenter.default.post(name: Notification.Name("FetchPreCreate"), object: self.tag, userInfo: nil)
                try? channel.close()
            }
        }
    }
    
    //check account payable with lowest fee
    override func isTxFeePayable() -> Bool {
        var result = false
        getDefaultFeeCoins().forEach { minFee in
            if (balanceAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                result = true
                return
            }
        }
        return result
    }
    
    func fetchStakeData() {
        if (cosmosValidators.count > 0) { return }
        Task {
            let channel = getConnection()
            if let bonded = try? await fetchBondedValidator(channel),
               let unbonding = try? await fetchUnbondingValidator(channel),
               let unbonded = try? await fetchUnbondedValidator(channel) {
                
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
                NotificationCenter.default.post(name: Notification.Name("FetchStakeData"), object: self.tag, userInfo: nil)
                try? channel.close()
            }
        }
    }
    
    func allStakingDenomAmount() -> NSDecimalNumber {
         return balanceAmount(stakeDenom).adding(vestingAmount(stakeDenom)).adding(delegationAmountSum())
            .adding(unbondingAmountSum()).adding(rewardAmountSum(stakeDenom)).adding(commissionAmount(stakeDenom))
    }
    
    func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if (denom == stakeDenom) {
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
        if (supportCw20) {
            if let tokenInfo = mintscanCw20Tokens.filter({ $0.address == address }).first {
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
            }
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        if (supportCw20) {
            mintscanCw20Tokens.forEach { tokenInfo in
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
        }
        return result
    }
    
    func monikerImg(_ opAddress: String) -> URL {
        return URL(string: ResourceBase + apiName + "/moniker/" + opAddress + ".png") ?? URL(string: "")!
    }
    
    override func getExplorerAccount() -> URL? {
        if let urlString = getChainListParam()["explorer"]["account"].string,
           let url = URL(string: urlString.replacingOccurrences(of: "${address}", with: bechAddress)) {
            return url
        }
        return nil
    }
    
    override func getExplorerTx(_ hash: String?) -> URL? {
        if let urlString = getChainListParam()["explorer"]["tx"].string,
           let txhash = hash,
           let url = URL(string: urlString.replacingOccurrences(of: "${hash}", with: txhash)) {
            return url
        }
        return nil
    }
    
    override func getExplorerProposal(_ id: UInt64) -> URL? {
        if let urlString = getChainListParam()["explorer"]["proposal"].string,
           let url = URL(string: urlString.replacingOccurrences(of: "${id}", with: String(id))) {
            return url
        }
        return nil
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
        return BaseData.instance.mintscanChainParams?[apiName] ?? JSON()
    }
    
    func getChainListParam() -> JSON {
        return getChainParam()["params"]["chainlist_params"] 
    }
    
    func isGasSimulable() -> Bool {
        return getChainListParam()["fee"]["isSimulable"].bool ?? true
    }
    
    func isBankLocked() -> Bool {
        return getChainListParam()["isBankLocked"].bool ?? false
    }
    
    func feeThreshold() -> String? {
        return nil
    }
    
    func voteThreshold() -> NSDecimalNumber {
        let threshold = getChainListParam()["voting_threshold"].uInt64Value
        return NSDecimalNumber(value: threshold)
    }
    
    func gasMultiply() -> Double {
        if let mutiply = getChainListParam()["fee"]["simul_gas_multiply"].double {
            return mutiply
        }
        return 1.2
    }
    
    func getFeeInfos() -> [FeeInfo] {
        var result = [FeeInfo]()
        getChainListParam()["fee"]["rate"].arrayValue.forEach { rate in
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
    
    func getBaseFeeInfo() -> FeeInfo {
        return getFeeInfos()[getFeeBasePosition()]
    }
    
    func getFeeBasePosition() -> Int {
        return getChainListParam()["fee"]["base"].intValue
    }
    
    func getFeeBaseGasAmount() -> UInt64 {
        guard let limit = getChainListParam()["fee"]["init_gas_limit"].uInt64 else {
            return UInt64(BASE_GAS_AMOUNT)!
        }
        return limit
    }
    
    func getFeeBaseGasAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: String(getFeeBaseGasAmount()))
    }
    
    //get chainlist suggest fees array
    func getDefaultFeeCoins() -> [Cosmos_Base_V1beta1_Coin] {
        var result = [Cosmos_Base_V1beta1_Coin]()
        let gasAmount: NSDecimalNumber = getFeeBaseGasAmount()
        if (getFeeInfos().count > 0) {
            let feeDatas = getFeeInfos()[getFeeBasePosition()].FeeDatas
            feeDatas.forEach { feeData in
                let amount = (feeData.gasRate)!.multiplying(by: gasAmount, withBehavior: handler0Up)
                result.append(Cosmos_Base_V1beta1_Coin.with {  $0.denom = feeData.denom!; $0.amount = amount.stringValue })
            }
        }
        return result
    }
    
    //get first payable fee with this account
    func getInitPayableFee() -> Cosmos_Tx_V1beta1_Fee? {
        var feeCoin: Cosmos_Base_V1beta1_Coin?
        for i in 0..<getDefaultFeeCoins().count {
            let minFee = getDefaultFeeCoins()[i]
            if (balanceAmount(minFee.denom).compare(NSDecimalNumber.init(string: minFee.amount)).rawValue >= 0) {
                feeCoin = minFee
                break
            }
        }
        if (feeCoin != nil) {
            return Cosmos_Tx_V1beta1_Fee.with {
                $0.gasLimit = getFeeBaseGasAmount()
                $0.amount = [feeCoin!]
            }
        }
        return nil
    }
    
    //get user selected fee
    func getUserSelectedFee(_ position: Int, _ denom: String) -> Cosmos_Tx_V1beta1_Fee {
        let gasAmount: NSDecimalNumber = getFeeBaseGasAmount()
        let feeDatas = getFeeInfos()[position].FeeDatas
        let rate = feeDatas.filter { $0.denom == denom }.first!.gasRate
        let coinAmount = rate!.multiplying(by: gasAmount, withBehavior: handler0Up)
        return Cosmos_Tx_V1beta1_Fee.with {
            $0.gasLimit = getFeeBaseGasAmount()
            $0.amount = [Cosmos_Base_V1beta1_Coin.with {  $0.denom = denom; $0.amount = coinAmount.stringValue }]
        }
    }
    
}


//about mintscan api
extension CosmosClass {
    
    func fetchCw20Info() async throws -> [MintscanToken]? {
        if (!supportCw20) { return [] }
        return try await AF.request(BaseNetWork.msCw20InfoUrl(self), method: .get).serializingDecodable([MintscanToken].self).value
    }
    
    func fetchCw721Info() async throws -> [JSON]? {
        if (!supportCw721) { return [] }
        return try await AF.request(BaseNetWork.msCw721InfoUrl(self), method: .get).serializingDecodable([JSON].self).value
    }
}


//about grpc
extension CosmosClass {
    
    func fetchBondedValidator(_ channel: ClientConnection?) async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        if (channel == nil) { return nil }
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 300 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_BONDED" }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel!).validators(req).response.get().validators
    }
    
    func fetchUnbondedValidator(_ channel: ClientConnection?) async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        if (channel == nil) { return nil }
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDED" }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel!).validators(req).response.get().validators
    }
    
    func fetchUnbondingValidator(_ channel: ClientConnection?) async throws -> [Cosmos_Staking_V1beta1_Validator]? {
        if (channel == nil) { return nil }
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 500 }
        let req = Cosmos_Staking_V1beta1_QueryValidatorsRequest.with { $0.pagination = page; $0.status = "BOND_STATUS_UNBONDING" }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel!).validators(req).response.get().validators
    }
    
    func fetchAuth(_ channel: ClientConnection?) async throws -> Google_Protobuf_Any? {
        if (channel == nil) { return nil }
        let req = Cosmos_Auth_V1beta1_QueryAccountRequest.with { $0.address = bechAddress }
        return try await Cosmos_Auth_V1beta1_QueryNIOClient(channel: channel!).account(req, callOptions: getCallOptions()).response.get().account
    }
    
    func fetchBalance(_ channel: ClientConnection?) async throws -> [Cosmos_Base_V1beta1_Coin]? {
        if (channel == nil) { return nil }
        let page = Cosmos_Base_Query_V1beta1_PageRequest.with { $0.limit = 2000 }
        let req = Cosmos_Bank_V1beta1_QueryAllBalancesRequest.with { $0.address = bechAddress; $0.pagination = page }
        return try await Cosmos_Bank_V1beta1_QueryNIOClient(channel: channel!).allBalances(req, callOptions: getCallOptions()).response.get().balances
    }
    
    func fetchDelegation(_ channel: ClientConnection?) async throws -> [Cosmos_Staking_V1beta1_DelegationResponse]? {
        if (channel == nil) { return nil }
        let req = Cosmos_Staking_V1beta1_QueryDelegatorDelegationsRequest.with { $0.delegatorAddr = bechAddress }
        return try await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel!).delegatorDelegations(req, callOptions: getCallOptions()).response.get().delegationResponses
    }
    
    func fetchUnbondings(_ channel: ClientConnection?) async throws -> [Cosmos_Staking_V1beta1_UnbondingDelegation]? {
        if (channel == nil) { return nil }
        let req = Cosmos_Staking_V1beta1_QueryDelegatorUnbondingDelegationsRequest.with { $0.delegatorAddr = bechAddress }
        return try? await Cosmos_Staking_V1beta1_QueryNIOClient(channel: channel!).delegatorUnbondingDelegations(req, callOptions: getCallOptions()).response.get().unbondingResponses
    }
    
    func fetchRewards(_ channel: ClientConnection?) async throws -> [Cosmos_Distribution_V1beta1_DelegationDelegatorReward]? {
        if (channel == nil) { return nil }
        let req = Cosmos_Distribution_V1beta1_QueryDelegationTotalRewardsRequest.with { $0.delegatorAddress = bechAddress }
        return try await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: channel!).delegationTotalRewards(req, callOptions: getCallOptions()).response.get().rewards
    }
    
    func fetchCommission(_ channel: ClientConnection?) async throws -> Cosmos_Distribution_V1beta1_ValidatorAccumulatedCommission? {
        if (channel == nil) { return nil }
        if (bechOpAddress == nil) { return nil }
        let req = Cosmos_Distribution_V1beta1_QueryValidatorCommissionRequest.with { $0.validatorAddress = bechOpAddress! }
        return try await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: channel!).validatorCommission(req, callOptions: getCallOptions()).response.get().commission
    }
    
    func fetchRewardAddress(_ channel: ClientConnection?) async throws -> String? {
        if (channel == nil) { return nil }
        let req = Cosmos_Distribution_V1beta1_QueryDelegatorWithdrawAddressRequest.with { $0.delegatorAddress = bechAddress }
        return try await Cosmos_Distribution_V1beta1_QueryNIOClient(channel: channel!).delegatorWithdrawAddress(req, callOptions: getCallOptions()).response.get().withdrawAddress
    }
    
    func fetchAllCw20Balance(_ id: Int64) {
        let channel = getConnection()
        let group = DispatchGroup()
        mintscanCw20Tokens.forEach { token in
            fetchCw20Balance(group, channel, token)
        }
        
        group.notify(queue: .main) {
            self.allTokenValue = self.allTokenValue()
            self.allTokenUSDValue = self.allTokenValue(true)
            
            BaseData.instance.updateRefAddressesTokenValue(
                RefAddress(id, self.tag, self.bechAddress, self.evmAddress,
                           nil, nil, self.allTokenUSDValue.stringValue, nil))
            NotificationCenter.default.post(name: Notification.Name("FetchTokens"), object: self.tag, userInfo: nil)
            try? channel.close()
        }
    }
    
    func fetchCw20Balance(_ group: DispatchGroup, _ channel: ClientConnection, _ tokenInfo: MintscanToken) {
        group.enter()
        DispatchQueue.global().async {
            let query: JSON = ["balance" : ["address" : self.bechAddress]]
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
    
    func fetchAllCw721() {
        cw721Fetched = false
        cw721Models.removeAll()
        Task {
            let channel = getConnection()
            await mintscanCw721List.concurrentForEach { list in
                var tokens = [Cw721TokenModel]()
                if let tokenIds = try? await self.fetchCw721TokenIds(channel, list), !tokenIds.isEmpty {
                    print("tokenIds ", list["name"], "  ", tokenIds)
                    await tokenIds["tokens"].arrayValue.concurrentForEach { tokenId in
//                        if let tokenInfo = try? await self.fetchCw721TokenInfo(channel, list, tokenId.stringValue),
//                           let tokenDetail = try? await AF.request(tokenInfo.ipfsUrl, method: .get).serializingDecodable(JSON.self).value {
//                            tokens.append(Cw721TokenModel.init(tokenId.stringValue, tokenInfo, tokenDetail))
//                        }
                        if let tokenInfo = try? await self.fetchCw721TokenInfo(channel, list, tokenId.stringValue) {
                            print("tokenInfo ", tokenInfo)
                            tokens.append(Cw721TokenModel.init(tokenId.stringValue, tokenInfo, nil))
                        }
                    }
                }
                if (!tokens.isEmpty) {
                    self.cw721Models.append(Cw721Model(list, tokens))
                }
            }
            DispatchQueue.main.async(execute: {
                self.cw721Fetched = true
                NotificationCenter.default.post(name: Notification.Name("FetchNFTs"), object: self.tag, userInfo: nil)
                try? channel.close()
            })
        }
        
    }
    
    func fetchCw721TokenIds(_ channel: ClientConnection, _ list: JSON) async throws -> JSON {
        let query: JSON = ["tokens" : ["owner" : self.bechAddress, "limit" : 50, "start_after" : "0"]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = list["contractAddress"].stringValue
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let result = try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.get().data,
           let tokenIds = try? JSONDecoder().decode(JSON.self, from: result), tokenIds["tokens"].arrayValue.count > 0 {
            return tokenIds
        }
        return JSON()
    }
    
    func fetchCw721TokenInfo(_ channel: ClientConnection, _ list: JSON, _ tokenId: String) async throws -> JSON {
        let query: JSON = ["nft_info" : ["token_id" : tokenId]]
        let queryBase64 = try! query.rawData(options: [.sortedKeys, .withoutEscapingSlashes]).base64EncodedString()
        let req = Cosmwasm_Wasm_V1_QuerySmartContractStateRequest.with {
            $0.address = list["contractAddress"].stringValue
            $0.queryData = Data(base64Encoded: queryBase64)!
        }
        if let result = try? await Cosmwasm_Wasm_V1_QueryNIOClient(channel: channel).smartContractState(req, callOptions: getCallOptions()).response.get().data,
           let tokenInfo = try? JSONDecoder().decode(JSON.self, from: result) {
            return tokenInfo
        }
        return JSON()
    }
    
    func balanceAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber(string: cosmosBalances?.filter { $0.denom == denom }.first?.amount ?? "0")
    }
    
    func balanceValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        let amount = balanceAmount(denom)
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
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
        cosmosUnbondings?.forEach({ unbonding in
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
        cosmosRewards?.forEach({ reward in
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
        cosmosRewards?.forEach({ reward in
            reward.reward.forEach { deCoin in
                if BaseData.instance.getAsset(apiName, deCoin.denom) != nil {
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
        rewardAllCoins().filter { $0.denom != stakeDenom }.forEach { reward in
            if (denoms.contains(reward.denom) == false) {
                denoms.append(reward.denom)
            }
        }
        return denoms.count
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
        cosmosRewards?.forEach { reward in
            for i in 0..<reward.reward.count {
                let rewardAmount = NSDecimalNumber(string: reward.reward[i].amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
                if let msAsset = BaseData.instance.getAsset(self.apiName, reward.reward[i].denom) {
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
                if let msAsset = BaseData.instance.getAsset(self.apiName, reward.reward[i].denom) {
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
    
    func commissionAmount(_ denom: String) -> NSDecimalNumber {
        return cosmosCommissions.filter { $0.denom == denom }.first?.getAmount() ?? NSDecimalNumber.zero
    }
    
    func commissionValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(apiName, denom) {
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
        return cosmosCommissions.filter { $0.denom != stakeDenom }.count
    }
    
    
    func getConnection() -> ClientConnection {
        let group = PlatformSupport.makeEventLoopGroup(loopCount: 4)
        return ClientConnection.usingPlatformAppropriateTLS(for: group).connect(host: getGrpc().host, port: getGrpc().port)
    }
    
    func getCallOptions() -> CallOptions {
        var callOptions = CallOptions()
        callOptions.timeLimit = TimeLimit.timeout(TimeAmount.milliseconds(8000))
        return callOptions
    }
}


func ALLCOSMOSCLASS() -> [CosmosClass] {
    var result = [CosmosClass]()
    result.removeAll()
    result.append(ChainCosmos())
    result.append(ChainAkash())
//    result.append(ChainAlthea118())
    result.append(ChainArchway())
    result.append(ChainAssetMantle())
    result.append(ChainAxelar())
    result.append(ChainBand())
    result.append(ChainBitcana())
    result.append(ChainBitsong())
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
    result.append(ChainFetchAi())
    result.append(ChainFetchAi60Secp())
    result.append(ChainFetchAi60Old())
    result.append(ChainFinschia())
    result.append(ChainGovgen())
    result.append(ChainGravityBridge())
    result.append(ChainInjective())
    result.append(ChainIris())
    result.append(ChainIxo())
    result.append(ChainJuno())
    result.append(ChainKava459())
    result.append(ChainKava118())
    result.append(ChainKi())
    result.append(ChainKyve())
    result.append(ChainLike())
    result.append(ChainLum880())
    result.append(ChainLum118())
    result.append(ChainMars())
    result.append(ChainMedibloc())
    result.append(ChainNeutron())
    result.append(ChainNibiru())
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
    result.append(ChainSaga())
    result.append(ChainSecret118())
    result.append(ChainSecret529())
    result.append(ChainSei())
    result.append(ChainSentinel())
    result.append(ChainShentu())
    result.append(ChainSommelier())
    result.append(ChainStafi())
    result.append(ChainStargaze())
    result.append(ChainStride())
    result.append(ChainTeritori())
    result.append(ChainTerra())
    result.append(ChainUmee())
    result.append(ChainXpla())
    
    result.append(ChainBinanceBeacon())
    result.append(ChainOkt996Secp())
    result.append(ChainOkt996Keccak())
    
    
    
//    result.append(ChainStarname())
    
    
    result.forEach { chain in
        if let cosmosChainId = chain.getChainListParam()["chain_id_cosmos"].string {
            chain.chainIdCosmos = cosmosChainId
        }
    }
    if (BaseData.instance.getHideLegacy()) {
        return result.filter({ $0.isDefault == true })
    }
    return result
}

let DEFUAL_DISPALY_COSMOS = ["cosmos118", "neutron118", "osmosis118", "dydx118", "crypto-org394", "celestia118"]

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


extension Cosmos_Base_V1beta1_DecCoin {
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber(string: amount).multiplying(byPowerOf10: -18, withBehavior: handler0Down)
    }
}


