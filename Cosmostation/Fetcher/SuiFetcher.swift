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
                
                if (suiBalances.filter { $0.0 == SUI_MAIN_DENOM }.count == 0) {
                    suiBalances.append((SUI_MAIN_DENOM, NSDecimalNumber.zero))
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
    
    func stakedAmount() -> NSDecimalNumber {
        var staked = NSDecimalNumber.zero
        var earned = NSDecimalNumber.zero
        suiStakedList.forEach { suiStaked in
            suiStaked["stakes"].arrayValue.forEach { stakes in
                staked = staked.adding(NSDecimalNumber(value: stakes["principal"].int64Value))
                earned = earned.adding(NSDecimalNumber(value: stakes["estimatedReward"].int64Value))
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
                staked = staked.adding(NSDecimalNumber(value: stakes["principal"].int64Value))
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
                earned = earned.adding(NSDecimalNumber(value: stakes["estimatedReward"].int64Value))
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
    func suiNfts() -> [JSON] {
        return suiObjects.filter { object in
            let typeS = object["type"].string?.lowercased()
            return (typeS?.contains("stakedsui") == false && typeS?.contains("coin") == false)
        }
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
}
