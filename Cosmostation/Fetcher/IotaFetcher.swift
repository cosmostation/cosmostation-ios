//
//  IotaFetcher.swift
//  Cosmostation
//
//  Created by 차소민 on 4/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class IotaFetcher {
    
    var chain: BaseChain!
    
    var iotaSystem = JSON()
    var iotaBalances = Array<(String, NSDecimalNumber)>()
    var iotaStakedList = [JSON]()
    var iotaObjects = [JSON]()
    var iotaValidators = [JSON]()
    var iotaApys = [JSON]()
    var iotaCoinMeta: [String: JSON] = [:]
    var iotaHistory = [JSON]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchIotaBalances() async -> Bool {
        iotaBalances.removeAll()
        if let balance = try? await fetchAllBalances(chain.mainAddress) {
            balance?["result"].arrayValue.forEach({ balance in
                let cointype = balance["coinType"].stringValue
                let amount = NSDecimalNumber.init(string: balance["totalBalance"].stringValue)
                iotaBalances.append((cointype, amount))
            })
            iotaBalances.sort {
                if ($0.0 == IOTA_MAIN_DENOM) { return true }
                if ($1.0 == IOTA_MAIN_DENOM) { return false }
                return false
            }
        }
        return true
    }
    
    func fetchIotaData(_ id: Int64) async -> Bool {
        iotaSystem = JSON()
        iotaBalances.removeAll()
        iotaStakedList.removeAll()
        iotaObjects.removeAll()
        iotaValidators.removeAll()
        iotaCoinMeta.removeAll()
        
        do {
            if let chainidentifier = try await fetchChainId(),
               let latestIotaSystemState = try await fetchSystemState(),
               let apys = try await fetchAPYs(),
               let _ = try? await fetchOwnedObjects(chain.mainAddress, nil),
               let stakes = try? await fetchStakes(chain.mainAddress) {
                
                iotaSystem = latestIotaSystemState["result"]
                iotaSystem["activeValidators"].arrayValue.forEach { validator in
                    iotaValidators.append(validator)
                }
                iotaValidators.sort {
                    if ($0["name"].stringValue == "Cosmostation") { return true }
                    if ($1["name"].stringValue == "Cosmostation") { return false }
                    return $0["votingPower"].intValue > $1["votingPower"].intValue ? true : false
                }
                iotaApys = apys
                iotaApys.sort {
                    return $0["apy"].doubleValue > $1["apy"].doubleValue ? true : false
                }
                
                iotaObjects.forEach { object in
                    if let coinType = object["type"].string?.iotaCoinType() {
                        if let index = iotaBalances.firstIndex(where: { $0.0 == coinType }) {
                            let alreadyAmount = iotaBalances[index].1
                            let sumAmount = alreadyAmount.adding(NSDecimalNumber.init(string:  object["content"]["fields"]["balance"].stringValue))
                            iotaBalances[index] = (coinType, sumAmount)
                        } else {
                            let newAmount = NSDecimalNumber.init(string: object["content"]["fields"]["balance"].stringValue)
                            iotaBalances.append((coinType, newAmount))
                        }
                    }
                }
                
                stakes?["result"].arrayValue.forEach({ stake in
                    iotaStakedList.append(stake)
                })
                
                await iotaBalances.concurrentForEach { coinType, balance in
                    if let metadata = try? await self.fetchCoinMetadata(coinType)?["result"], metadata != JSON.null {
                        self.iotaCoinMeta[coinType] = metadata
                    }
                }
            }
            return true
            
        } catch {
            print("iota error \(error) ", chain.tag)
            return false
        }
    }
    
    func fetchIotaHistory() async {
        iotaHistory.removeAll()
        
        if let fromHistory = try? await fetchFromHistory(chain.mainAddress),
           let toHistory = try? await fetchToHistory(chain.mainAddress) {
            iotaHistory.append(contentsOf: fromHistory ?? [])
            toHistory?.forEach { to in
                if (iotaHistory.filter({ $0["digest"].stringValue == to["digest"].stringValue }).first == nil) {
                    iotaHistory.append(to)
                }
            }
            iotaHistory.sort {
                return $0["checkpoint"].int64Value > $1["checkpoint"].int64Value
            }
        }
        return
    }
    
    
    func stakedAmount() -> NSDecimalNumber {
        var staked = NSDecimalNumber.zero
        var earned = NSDecimalNumber.zero
        iotaStakedList.forEach { iotaStaked in
            iotaStaked["stakes"].arrayValue.forEach { stakes in
                staked = staked.adding(NSDecimalNumber(value: stakes["principal"].uInt64Value))
                earned = earned.adding(NSDecimalNumber(value: stakes["estimatedReward"].uInt64Value))
            }
        }
        return staked.adding(earned)
    }
    
    func stakedValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = stakedAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, IOTA_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func principalAmount() -> NSDecimalNumber {
        var staked = NSDecimalNumber.zero
        iotaStakedList.forEach { iotaStaked in
            iotaStaked["stakes"].arrayValue.forEach { stakes in
                staked = staked.adding(NSDecimalNumber(value: stakes["principal"].uInt64Value))
            }
        }
        return staked
    }
    
    func principalValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = principalAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, IOTA_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func estimatedRewardAmount() -> NSDecimalNumber {
        var earned = NSDecimalNumber.zero
        iotaStakedList.forEach { iotaStaked in
            iotaStaked["stakes"].arrayValue.forEach { stakes in
                earned = earned.adding(NSDecimalNumber(value: stakes["estimatedReward"].uInt64Value))
            }
        }
        return earned
    }
    
    func estimatedRewardValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = estimatedRewardAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, IOTA_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    
    func balanceAmount(_ coinType: String) -> NSDecimalNumber {
        if let iotaCoin = iotaBalances.filter({ $0.0 == coinType }).first {
            return iotaCoin.1
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
        iotaBalances.forEach { balance in
            result = result.adding(balanceValue(balance.0, usd))
        }
        return result
    }
    
    func allIotaAmount() -> NSDecimalNumber {
        return stakedAmount().adding(balanceAmount(IOTA_MAIN_DENOM))
    }
    
    func allIotaValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let amount = allIotaAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, IOTA_MAIN_DENOM) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return allBalanceValue(usd).adding(stakedValue(usd))
    }
    
    //TODO check nft logic match with android & extension
    func allNfts() -> [JSON] {
        return iotaObjects.filter { object in
            let typeS = object["type"].string?.lowercased()
            return (typeS?.contains("stakediota") == false && typeS?.contains("coin") == false)
        }
    }
    
    
    func hasFee(_ txType: TxType?) -> Bool {
        let iotaBalance = balanceAmount(IOTA_MAIN_DENOM)
        return iotaBalance.compare(baseFee(txType)).rawValue > 0
    }
    
    //test
    func baseFee(_ txType: TxType?) -> NSDecimalNumber {
        if (txType == .IOTA_SEND_COIN || txType == .IOTA_SEND_NFT) {
            return SUI_FEE_SEND
        } else if (txType == .IOTA_STAKE) {
            return SUI_FEE_STAKE
        } else if (txType == .IOTA_UNSTAKE) {
            return SUI_FEE_UNSTAKE
        }
        return SUI_FEE_DEFAULT
    }
    
    
    func getIotaRpc() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.mainUrl
    }
}

extension IotaFetcher {
    
    func fetchChainId() async throws -> JSON? {
        let parameters: Parameters = ["method": "iota_getChainIdentifier", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchSystemState() async throws -> JSON? {
        let parameters: Parameters = ["method": "iotax_getLatestIotaSystemState", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchAllBalances(_ address: String) async throws -> JSON?  {
        let parameters: Parameters = ["method": "iotax_getAllBalances", "params": [address], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchOwnedObjects(_ address: String, _ cursor: String?) async throws {
        var params: Any!
        if (cursor == nil) {
            params = [address, ["filter": nil, "options":["showContent":true, "showDisplay":true,  "showType":true]]]
        } else {
            params = [address, ["filter": nil, "options":["showContent":true, "showDisplay":true,  "showType":true]], cursor!]
        }
        let parameters: Parameters = ["method": "iotax_getOwnedObjects", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        if let response = try? await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value {
//            print("response ", response)
            response["result"]["data"].arrayValue.forEach({ data in
                iotaObjects.append(data["data"])
            })
            if (response["result"]["hasNextPage"].bool == true && response["result"]["nextCursor"].string != nil) {
                try await fetchOwnedObjects(address, response["result"]["nextCursor"].stringValue)
            }
        }
    }
    
    func fetchStakes(_ address: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "iotax_getStakes", "params": [address], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchCoinMetadata(_ coinType: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "iotax_getCoinMetadata", "params": [coinType], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchGasprice() async throws -> NSDecimalNumber {
        let parameters: Parameters = ["method": "iotax_getReferenceGasPrice", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        if let price = try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"].string {
            return NSDecimalNumber.init(string: price)
        }
        return NSDecimalNumber.zero
    }
    
    func fetchAPYs() async throws -> [JSON]?  {
        let parameters: Parameters = ["method": "iotax_getValidatorsApy", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["apys"].array
    }
    
    func fetchFromHistory(_ address: String) async throws -> [JSON]? {
        let params: Any = [["filter": ["FromAddress": address], "options": ["showEffects": true, "showInput":true, "showBalanceChanges":true]], nil, 50, true]
        let parameters: Parameters = ["method": "iotax_queryTransactionBlocks", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["data"].array
    }
    
    func fetchToHistory(_ address: String) async throws -> [JSON]? {
        let params: Any = [["filter": ["ToAddress": address], "options": ["showEffects": true, "showInput":true, "showBalanceChanges":true]], nil, 50, true]
        let parameters: Parameters = ["method": "iotax_queryTransactionBlocks", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["data"].array
    }
    
    
    func unsafeCoinSend(_ sendDenom: String, _ sender: String, _ coins: [String], _ recipients: [String], _ amounts: [String], _ gasBudget: String) async throws -> String? {
        if (sendDenom == IOTA_MAIN_DENOM) {
            return try await unsafePayIota(sender, coins, recipients, amounts, gasBudget)
        }
        return try await unsafePay(sender, coins, recipients, amounts, gasBudget)
    }
    
    func unsafePayIota(_ sender: String, _ coins: [String], _ recipients: [String], _ amounts: [String], _ gasBudget: String) async throws -> String? {
        let params: Any = [sender, coins,  recipients, amounts, gasBudget]
        let parameters: Parameters = ["method": "unsafe_payIota", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try? await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["txBytes"].stringValue
    }
    
    func unsafePay(_ sender: String, _ coins: [String], _ recipients: [String], _ amounts: [String], _ gasBudget: String) async throws -> String? {
        let params: Any = [sender, coins,  recipients, amounts, NSNull(), gasBudget]
        let parameters: Parameters = ["method": "unsafe_pay", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try? await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["txBytes"].stringValue
    }
    
    func unsafeTransferObject(_ sender: String, _ objectId: String, _ gasBudget: String, _ recipients: String) async throws -> String? {
        let params: Any = [sender, objectId, NSNull(),  gasBudget, recipients]
        let parameters: Parameters = ["method": "unsafe_transferObject", "params": params, "id" : 1, "jsonrpc" : "2.0"]
        return try? await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]["txBytes"].stringValue
    }
    
    func unsafeStake(_ sender: String, _ coins: [String], _ amount: String, _ validator: String, _ gasBudget: String) async throws -> String? {
        if let result = try? await AF.request("https://us-central1-splash-wallet-60bd6.cloudfunctions.net/buildStakingRequest",
                                              method: .post,
                                              parameters: ["address" : sender, "validatorAddress" : validator, "gas" : gasBudget, "amount" : amount, "rpc": getIotaRpc()],
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
                                              parameters: ["address" : sender, "objectId" : objectId, "gas" : gasBudget, "rpc": getIotaRpc()],
                                              encoder: JSONParameterEncoder.default).serializingData().value {
            if let string = String(data: result, encoding: .utf8) {
                return Data(hex: string).base64EncodedString()
            }
        }
        return nil
    }
    
    func iotaDryrun(_ tx_bytes: String) async throws -> JSON? {
        let parameters: Parameters = ["method": "iota_dryRunTransactionBlock", "params": [tx_bytes], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func iotaExecuteTx(_ tx_bytes: String, _ signatures: [String], _ options: JSON?) async throws -> JSON? {
        if let options {
            
            var defaultOptions = ["showInput": true, "showEffects": true, "showEvents": true]
            
            for (key, value) in options.dictionaryValue {
                defaultOptions[key] = value.boolValue
            }
            
            let params: Any = [tx_bytes, signatures, defaultOptions, "WaitForLocalExecution"]
            let parameters: Parameters = ["method": "iota_executeTransactionBlock", "params": params, "id" : 1, "jsonrpc" : "2.0"]
            return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value

        } else {
            let params: Any = [tx_bytes, signatures, ["showEffects": true], "WaitForLocalExecution"]
            let parameters: Parameters = ["method": "iota_executeTransactionBlock", "params": params, "id" : 1, "jsonrpc" : "2.0"]
            return try await AF.request(getIotaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        }
    }
    
    func signAfterAction(params:JSON, messageId: JSON) async throws -> String? { //
        let url = "https://us-central1-splash-wallet-60bd6.cloudfunctions.net/buildSuiTransaction"
        let parameters = [
            "rpc": getIotaRpc(),
            "txBlock": params["transactionBlockSerialized"].stringValue,
            "address": params["transactionBlockSerialized"]["sender"].string ?? chain.mainAddress
        ]
        guard let value = await AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingData().response.value else { return nil }
        return String(data: value, encoding: .utf8)
    }
}


extension String {
    func iotaIsCoinType() -> Bool {
        return self.starts(with: IOTA_TYPE_COIN)
    }
    
    /*
     * "0x2::coin::Coin<0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT> ->  0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT
     */
    func iotaCoinType() -> String? {
        if (!iotaIsCoinType()) { return nil }
        let pattern = "<(.+)>"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        if let match = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
            if let range = Range(match.range(at: 1), in: self) {
                return String(self[range])
            }
        }
        return nil
    }
    
    /*
     * "0x2::coin::Coin<0x549e8b69270defbfafd4f94e17ec44cdbdd99820b33bda2278dea3b9a32d3f55::cert::CERT> ->  CERT
     */
    func iotaCoinSymbol() -> String? {
        let pattern = "::([a-zA-Z0-9_]+)(?:<.*>)?$"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        if let match = regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) {
            if let range = Range(match.range(at: 1), in: self) {
                return String(self[range])
            }
        }
        return nil
    }
}


extension JSON {
    func iotaValidatorImg() -> URL? {
        if let imageUrl = self["imageUrl"].string,
            imageUrl.isEmpty == false {
            return URL(string: imageUrl)
        }
        return nil
    }
    
    func iotaValidatorName() -> String {
        return self["name"].stringValue
    }
    
    func iotaValidatorCommission() -> NSDecimalNumber {
        return NSDecimalNumber(string: self["commissionRate"].stringValue).multiplying(byPowerOf10: -2, withBehavior: handler2)
    }
    
    func iotaValidatorVp() -> NSDecimalNumber {
        return NSDecimalNumber(string: self["stakingPoolIotaBalance"].stringValue).multiplying(byPowerOf10: -9, withBehavior: handler12Down)
    }
}

