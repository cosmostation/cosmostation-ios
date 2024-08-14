//
//  SuiFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/1/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SuiFetcher {
    
    var chain: BaseChain!
    
    var suiSystem = JSON()
    var suiBalances = Array<(String, NSDecimalNumber)>()
    var suiStakedList = [JSON]()
    var suiObjects = [JSON]()
    var suiValidators = [JSON]()
    var suiCoinMeta: [String: JSON] = [:]
    var suiHistory = [JSON]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    
    }
    
    func fetchSuiBalances() async -> Bool {
        suiBalances.removeAll()
        if let balance = try? await fetchAllBalances(chain.mainAddress) {
            balance?["result"].arrayValue.forEach({ balance in
                let cointype = balance["coinType"].stringValue
                let amount = NSDecimalNumber.init(string: balance["totalBalance"].stringValue)
                suiBalances.append((cointype, amount))
            })
            suiBalances.sort {
                if ($0.0 == SUI_MAIN_DENOM) { return true }
                if ($1.0 == SUI_MAIN_DENOM) { return false }
                return false
            }
        }
        return true
    }
    
    func fetchSuiData(_ id: Int64) async -> Bool {
        suiSystem = JSON()
        suiBalances.removeAll()
        suiStakedList.removeAll()
        suiObjects.removeAll()
        suiValidators.removeAll()
        suiCoinMeta.removeAll()
        
        do {
            if let chainidentifier = try await fetchChainId(),
               let latestSuiSystemState = try await fetchSystemState(),
               let _ = try? await fetchOwnedObjects(chain.mainAddress, nil),
               let stakes = try? await fetchStakes(chain.mainAddress) {
                
                suiSystem = latestSuiSystemState["result"]
                suiSystem["activeValidators"].arrayValue.forEach { validator in
                    suiValidators.append(validator)
                }
                suiValidators.sort {
                    if ($0["name"].stringValue == "Cosmostation") { return true }
                    if ($1["name"].stringValue == "Cosmostation") { return false }
                    return $0["votingPower"].intValue > $1["votingPower"].intValue ? true : false
                }
                
                suiObjects.forEach { object in
                    if let coinType = object["type"].string?.suiCoinType() {
                        if let index = suiBalances.firstIndex(where: { $0.0 == coinType }) {
                            let alreadyAmount = suiBalances[index].1
                            let sumAmount = alreadyAmount.adding(NSDecimalNumber.init(string:  object["content"]["fields"]["balance"].stringValue))
                            suiBalances[index] = (coinType, sumAmount)
                        } else {
                            let newAmount = NSDecimalNumber.init(string: object["content"]["fields"]["balance"].stringValue)
                            suiBalances.append((coinType, newAmount))
                        }
                    }
                }
                
                stakes?["result"].arrayValue.forEach({ stake in
                    suiStakedList.append(stake)
                })
                
                await suiBalances.concurrentForEach { coinType, balance in
                    if let metadata = try? await self.fetchCoinMetadata(coinType) {
                        self.suiCoinMeta[coinType] = metadata?["result"]
                    }
                }
            }
            return true
            
        } catch {
            print("sui error \(error) ", chain.tag)
            return false
        }
    }
    
    func fetchSuiHistory() async {
        suiHistory.removeAll()
        
        if let fromHistroy = try? await fetchFromHistroy(chain.mainAddress),
           let toHistroy = try? await fetchToHistroy(chain.mainAddress) {
            suiHistory.append(contentsOf: fromHistroy ?? [])
            toHistroy?.forEach { to in
                if (suiHistory.filter({ $0["digest"].stringValue == to["digest"].stringValue }).first == nil) {
                    suiHistory.append(to)
                }
            }
            suiHistory.sort {
                return $0["checkpoint"].int64Value > $1["checkpoint"].int64Value
            }
        }
        return
    }
    
    
    func stakedAmount() -> NSDecimalNumber {
        var staked = NSDecimalNumber.zero
        var earned = NSDecimalNumber.zero
        suiStakedList.forEach { suiStaked in
            suiStaked["stakes"].arrayValue.forEach { stakes in
                staked = staked.adding(NSDecimalNumber(value: stakes["principal"].uInt64Value))
                earned = earned.adding(NSDecimalNumber(value: stakes["estimatedReward"].uInt64Value))
            }
        }
        return staked.adding(earned)
    }
    
    func stakedValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = stakedAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func principalAmount() -> NSDecimalNumber {
        var staked = NSDecimalNumber.zero
        suiStakedList.forEach { suiStaked in
            suiStaked["stakes"].arrayValue.forEach { stakes in
                staked = staked.adding(NSDecimalNumber(value: stakes["principal"].uInt64Value))
            }
        }
        return staked
    }
    
    func principalValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = principalAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func estimatedRewardAmount() -> NSDecimalNumber {
        var earned = NSDecimalNumber.zero
        suiStakedList.forEach { suiStaked in
            suiStaked["stakes"].arrayValue.forEach { stakes in
                earned = earned.adding(NSDecimalNumber(value: stakes["estimatedReward"].uInt64Value))
            }
        }
        return earned
    }
    
    func estimatedRewardValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = estimatedRewardAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    
    func balanceAmount(_ coinType: String) -> NSDecimalNumber {
        if let suiCoin = suiBalances.filter({ $0.0 == coinType }).first {
            return suiCoin.1
        }
        return NSDecimalNumber.zero
    }
    
    func balanceValue(_ coinType: String, _ usd: Bool? = false) -> NSDecimalNumber {
        let amount = balanceAmount(coinType)
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, coinType) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allBalanceValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        suiBalances.forEach { balance in
            result = result.adding(balanceValue(balance.0, usd))
        }
        return result
    }
    
    func allSuiAmount() -> NSDecimalNumber {
        return stakedAmount().adding(balanceAmount(SUI_MAIN_DENOM))
    }
    
    func allSuiValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = allSuiAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, SUI_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return allBalanceValue(usd).adding(stakedValue(usd))
    }
    
    //TODO chekc nft logic match with android & extention
    func allNfts() -> [JSON] {
        return suiObjects.filter { object in
            let typeS = object["type"].string?.lowercased()
            return (typeS?.contains("stakedsui") == false && typeS?.contains("coin") == false)
        }
    }
    
    
    func hasFee(_ txType: TX_TYPE?) -> Bool {
        let suiBalance = balanceAmount(SUI_MAIN_DENOM)
        return suiBalance.compare(baseFee(txType)).rawValue > 0
    }
    
    func baseFee(_ txType: TX_TYPE?) -> NSDecimalNumber {
        if (txType == .SUI_SEND_COIN || txType == .SUI_SEND_NFT) {
            return SUI_FEE_SEND
        } else if (txType == .SUI_STAKE) {
            return SUI_FEE_STAKE
        } else if (txType == .SUI_UNSTAKE) {
            return SUI_FEE_UNSTAKE
        }
        return SUI_FEE_DEFAULT
    }
    
    
    func getSuiRpc() -> String {
        return chain.mainUrl
    }
}


/**
 *   suix_getAllBalances         gives sui coin type as  0x2::coin::Coin
 *   suix_getOwnedObjects    gives sui coin type as  0x2::coin::Coin<0x2::sui::SUI>
 *
 *    we using 0x2::coin::Coin<0x2::sui::SUI> as amin sui default coin denom
 */
extension SuiFetcher {
    
    func fetchChainId() async throws -> JSON? {
        let parameters: Parameters = ["method": "sui_getChainIdentifier", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchSystemState() async throws -> JSON? {
        let parameters: Parameters = ["method": "suix_getLatestSuiSystemState", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchAllBalances(_ address: String) async throws -> JSON?  {
        let parameters: Parameters = ["method": "suix_getAllBalances", "params": [address], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchOwnedObjects(_ address: String, _ cursor: String?) async throws {
        var params: Any!
        if (cursor == nil) {
            params = [address, ["filter": nil, "options":["showContent":true, "showDisplay":true,  "showType":true]]]
        } else {
            params = [address, ["filter": nil, "options":["showContent":true, "showDisplay":true,  "showType":true]], cursor!]
        }
        let parameters: Parameters = ["method": "suix_getOwnedObjects", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        if let response = try? await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value {
//            print("response ", response)
            response["result"]["data"].arrayValue.forEach({ data in
                suiObjects.append(data["data"])
            })
            if (response["result"]["hasNextPage"].bool == true && response["result"]["nextCursor"].string != nil) {
                try await fetchOwnedObjects(address, response["result"]["nextCursor"].stringValue)
            }
        }
    }
    
    func fetchStakes(_ address: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "suix_getStakes", "params": [address], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchCoinMetadata(_ coinType: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "suix_getCoinMetadata", "params": [coinType], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchGasprice() async throws -> NSDecimalNumber {
        let parameters: Parameters = ["method": "suix_getReferenceGasPrice", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        if let price = try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"].string {
            return NSDecimalNumber.init(string: price)
        }
        return NSDecimalNumber.zero
    }
    
    func fetchFromHistroy(_ address: String) async throws -> [JSON]? {
        let params: Any = [["filter": ["FromAddress": address], "options": ["showEffects": true, "showInput":true, "showBalanceChanges":true]], nil, 50, true]
        let parameters: Parameters = ["method": "suix_queryTransactionBlocks", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["data"].array
    }
    
    func fetchToHistroy(_ address: String) async throws -> [JSON]? {
        let params: Any = [["filter": ["ToAddress": address], "options": ["showEffects": true, "showInput":true, "showBalanceChanges":true]], nil, 50, true]
        let parameters: Parameters = ["method": "suix_queryTransactionBlocks", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["data"].array
    }
    
    
    func unsafeCoinSend(_ sendDenom: String, _ sender: String, _ coins: [String], _ receipients: [String], _ amounts: [String], _ gasBudget: String) async throws -> String? {
        if (sendDenom == SUI_MAIN_DENOM) {
            return try await unsafePaySui(sender, coins, receipients, amounts, gasBudget)
        }
        return try await unsafePay(sender, coins, receipients, amounts, gasBudget)
    }
    
    func unsafePaySui(_ sender: String, _ coins: [String], _ receipients: [String], _ amounts: [String], _ gasBudget: String) async throws -> String? {
        let params: Any = [sender, coins,  receipients, amounts, gasBudget]
        let parameters: Parameters = ["method": "unsafe_paySui", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try? await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["txBytes"].stringValue
    }
    
    func unsafePay(_ sender: String, _ coins: [String], _ receipients: [String], _ amounts: [String], _ gasBudget: String) async throws -> String? {
        let params: Any = [sender, coins,  receipients, amounts, NSNull(), gasBudget]
        let parameters: Parameters = ["method": "unsafe_pay", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try? await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["txBytes"].stringValue
    }
    
    func unsafeTransferObject(_ sender: String, _ objectId: String, _ gasBudget: String, _ receipients: String) async throws -> String? {
        let params: Any = [sender, objectId, NSNull(),  gasBudget, receipients]
        let parameters: Parameters = ["method": "unsafe_transferObject", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try? await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["txBytes"].stringValue
    }
    
    func unsafeStake(_ sender: String, _ coins: [String], _ amount: String, _ validator: String, _ gasBudget: String) async throws -> String? {
        if let result = try? await AF.request("https://us-central1-splash-wallet-60bd6.cloudfunctions.net/buildStakingRequest",
                                              method: .post,
                                              parameters: ["address" : sender, "validatorAddress" : validator, "gas" : gasBudget, "amount" : amount, "rpc": getSuiRpc()],
                                              encoder: JSONParameterEncoder.default).serializingData().value {
            if let string = String(data: result, encoding: .utf8) {
                return Data(hex: string).base64EncodedString()
            }
        }
        return nil
    }
    
    func unsafeUnstake(_ sender: String, _ objectId: String, _ gasBudget: String) async throws -> String? {
        if let result = try? await AF.request("https://us-central1-splash-wallet-60bd6.cloudfunctions.net/buildUnstakingRequest",
                                              method: .post,
                                              parameters: ["address" : sender, "objectId" : objectId, "gas" : gasBudget, "rpc": getSuiRpc()],
                                              encoder: JSONParameterEncoder.default).serializingData().value {
            if let string = String(data: result, encoding: .utf8) {
                return Data(hex: string).base64EncodedString()
            }
        }
        return nil
    }
    
    func suiDryrun(_ tx_bytes: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "sui_dryRunTransactionBlock", "params": [tx_bytes], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func suiExecuteTx(_ tx_bytes: String, _ signatures: [String]) async throws -> JSON? {
        let params: Any = [tx_bytes, signatures, ["showEffects": true], "WaitForLocalExecution"]
        let parameters: Parameters = ["method": "sui_executeTransactionBlock", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSuiRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
}


extension String {
    func suiIsCoinType() -> Bool {
        return self.starts(with: SUI_TYPE_COIN)
    }
    
    /*
     * "0x2::coin::Coin<0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT> ->  0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT
     */
    func suiCoinType() -> String? {
        if (!suiIsCoinType()) { return nil }
        if let s1 = self.components(separatedBy: "<").last,
           let s2 = s1.components(separatedBy: ">").first {
            return s2
        }
        return nil
    }
    
    /*
     * "0x2::coin::Coin<0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT> ->  CERT
     */
    func suiCoinSymbol() -> String? {
        if (!suiIsCoinType()) { return nil }
        if let s1 = self.components(separatedBy: "<").last,
           let s2 = s1.components(separatedBy: ">").first,
           let symbol = s2.components(separatedBy: "::").last {
            return symbol
        }
        return nil
    }
}


extension JSON {
    func assetImg() -> URL {
        return URL(string: self["iconUrl"].stringValue) ?? URL(string: "")!
    }
    
    func suiValidatorImg() -> URL? {
        if let imageUrl = self["imageUrl"].string, 
            imageUrl.isEmpty == false {
            return URL(string: imageUrl)
        }
        return nil
    }
    
    func suiValidatorName() -> String {
        return self["name"].stringValue
    }
    
    func suiValidatorCommission() -> NSDecimalNumber {
        return NSDecimalNumber(string: self["commissionRate"].stringValue).multiplying(byPowerOf10: -2, withBehavior: handler2)
    }
    
    func suiValidatorVp() -> NSDecimalNumber {
        return NSDecimalNumber(string: self["stakingPoolSuiBalance"].stringValue).multiplying(byPowerOf10: -9, withBehavior: handler12Down)
    }
}

