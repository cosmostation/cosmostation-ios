//
//  GnoFetcher.swift
//  Cosmostation
//
//  Created by 차소민 on 2/3/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class GnoFetcher {
    var chain: BaseChain!
    
    var gnoPublicKey: String?
    var gnoAccountNumber: UInt64?
    var gnoSequenceNum: UInt64?
    var gnoBalances: [Cosmos_Base_V1beta1_Coin]?
    var gnoVestings: [Cosmos_Base_V1beta1_Coin]?
    var gnoHistory = [JSON]()
    
    var mintscanGrc20Tokens = [MintscanToken]()

    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchGnoBalances() async -> Bool {
        gnoBalances = [Cosmos_Base_V1beta1_Coin]()
        gnoVestings = nil
        let _ = try? await fetchAuth()
        return true
    }
    
    func fetchGnoData(_ id: Int64) async -> Bool {
        mintscanGrc20Tokens.removeAll()
        gnoBalances = nil
        
        do {
            if let _ = try? await fetchAuth() {
                self.mintscanGrc20Tokens = BaseData.instance.mintscanGrc20Tokens?.filter({ $0.chainName == chain.apiName }).map { token in
                    return token.copy() as! MintscanToken
                } ?? []
                
                let userDisplayGrc20token = BaseData.instance.getDisplayGrc20s(id, self.chain.tag)
                await mintscanGrc20Tokens.concurrentForEach { grc20 in
                    if (userDisplayGrc20token == nil) {
                        if (grc20.wallet_preload == true) {
                            await self.fetchGrc20Balance(grc20)
                        }
                        
                    } else {
                        if (userDisplayGrc20token?.contains(grc20.address!) == true) {
                            await self.fetchGrc20Balance(grc20)
                        }
                    }
                }
            }
            return true
            
        } catch {
            print("fetch Gno error \(error) ", chain.tag)
            return false
        }
        
    }
    
    func fetchGnoHistory() async {
        gnoHistory.removeAll()

        guard var result = try? await fetchHistory(chain.bechAddress!) else { return }

        let heights = Array(Set(result.compactMap { $0["block_height"].int64 }))
        if (heights.isEmpty == false), let timeMap = try? await fetchBlockTimes(heights) {
            for i in 0..<result.count {
                if let height = result[i]["block_height"].int64, let time = timeMap[height] {
                    result[i]["time"] = JSON(time)
                }
            }
        }
        gnoHistory = result
    }

    func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValue(denom, usd).adding(vestingValue(denom, usd))
    }
    
    func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(chain.stakingAssetDenom())
    }

    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd).adding(vestingValueSum(usd))
    }
    
    func valueCoinCnt() -> Int {
        return gnoBalances?.filter({ BaseData.instance.getAsset(chain.apiName, $0.denom) != nil }).count ?? 0
    }
    
    func valueTokenCnt(_ id: Int64) -> Int {
        if let tokens = BaseData.instance.getDisplayGrc20s(id, chain.tag) {
            return tokens.count
            
        } else {
            return mintscanGrc20Tokens.filter({ $0.getAmount() != NSDecimalNumber.zero }).count
        }
    }
}


extension GnoFetcher {
    
    func tokenValue(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if chain.isSupportGrc20() {
            if let tokenInfo = mintscanGrc20Tokens.filter({ $0.address == address }).first {
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                if msPrice != 0 {
                    return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                }
            }
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ id: Int64, _ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        
        if let tokens = BaseData.instance.getDisplayGrc20s(id, chain.tag) {
            mintscanGrc20Tokens.filter({ tokens.contains($0.address ?? "") }).forEach { tokenInfo in
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
            
        } else {
            mintscanGrc20Tokens.filter({ $0.wallet_preload == true }).forEach { tokenInfo in
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
        }
        
        return result
    }
    
    func balanceAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber(string: gnoBalances?.filter { $0.denom == denom }.first?.amount ?? "0")
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
        gnoBalances?.forEach { balance in
            result = result.adding(balanceValue(balance.denom, usd))
        }
        return result
    }
    
    func vestingAmount(_ denom: String) -> NSDecimalNumber {
        return NSDecimalNumber(string: gnoVestings?.filter { $0.denom == denom }.first?.amount ?? "0")
    }
    
    func vestingValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        let amount = vestingAmount(denom)
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, denom) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func vestingValueSum(_ usd: Bool? = false) -> NSDecimalNumber {
        var result =  NSDecimalNumber.zero
        gnoVestings?.forEach { vesting in
            result = result.adding(vestingValue(vesting.denom, usd))
        }
        return result
    }
}


extension GnoFetcher {
    
    func fetchAuth() async throws {
        gnoPublicKey = nil
        gnoAccountNumber = nil
        gnoSequenceNum = nil
        gnoVestings = nil
        
        let params: Parameters = ["jsonrpc":"2.0",
                                  "method": "abci_query",
                                  "params": ["auth/accounts/\(chain.bechAddress!)", "", "0", false],
                                  "id": 1]
        let response = try await AF.request(getRpc(), method: .post, parameters: params, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        let encodedDataString = response["result"]["response"]["ResponseBase"]["Data"].stringValue
        let data = Data(base64Encoded: encodedDataString)
        
        if String(data: data!, encoding: .utf8) == "null" {
            gnoBalances = [Cosmos_Base_V1beta1_Coin.init(chain.stakeDenom, "0")]
            return
        }
        
        let jsonData = try JSON(data: data!)
        let accountData = jsonData["BaseAccount"]
        
        if accountData["public_key"] != JSON.null {
            gnoPublicKey = accountData["public_key"]["value"].stringValue
        }
        gnoAccountNumber = UInt64(accountData["account_number"].stringValue)
        gnoSequenceNum = UInt64(accountData["sequence"].stringValue)
        
        if accountData["vesting"] != JSON.null {
            let vestingData = accountData["vesting"]
            let (originalVestingAmount, vestingDenom) = vestingData["original_vesting"].stringValue.gnoAmountAndDenom()
            let startTime = Int64(vestingData["start_time"].stringValue) ?? 0
            let endTime = Int64(vestingData["end_time"].stringValue) ?? 0
            let now = Int64(Date().timeIntervalSince1970)
            
            let duration = max(endTime - startTime, 1)
            let elapsed = min(max(now - startTime, 0), duration)
            
            let originalVesting = NSDecimalNumber(string: originalVestingAmount)
            let vested = originalVesting.multiplying(by: NSDecimalNumber(value: elapsed))
                .dividing(by: NSDecimalNumber(value: duration), withBehavior: handler0Down)
            var locked = originalVesting.subtracting(vested)
            if (locked.compare(NSDecimalNumber.zero) == .orderedAscending) { locked = NSDecimalNumber.zero }
            
            let (totalBalanceAmount, balanceDenom) = accountData["coins"].stringValue.gnoAmountAndDenom()
            let total = NSDecimalNumber(string: totalBalanceAmount)
            var spendable = total.subtracting(locked)
            if (spendable.compare(NSDecimalNumber.zero) == .orderedAscending) { spendable = NSDecimalNumber.zero }
            
            let denom = balanceDenom.isEmpty ? vestingDenom : balanceDenom
            gnoBalances = [Cosmos_Base_V1beta1_Coin.init(denom, spendable.stringValue)]
            gnoVestings = [Cosmos_Base_V1beta1_Coin.init(vestingDenom, locked.stringValue)]
            
        } else {
            let coins = accountData["coins"].stringValue
            if (coins.isEmpty) {
                gnoBalances = [Cosmos_Base_V1beta1_Coin.init(chain.stakeDenom, "0")]
                gnoVestings = [Cosmos_Base_V1beta1_Coin.init(chain.stakeDenom, "0")]
            } else {
                let (amount, denom) = coins.gnoAmountAndDenom()
                gnoBalances = [Cosmos_Base_V1beta1_Coin.init(denom, amount)]
            }
        }
    }
    
    func fetchHistory(_ address: String) async throws -> [JSON] {
        let parameters: Parameters = ["query": GNO_HISTORY_QUERY, "variables": ["addr": address]]
        let response = try await AF.request(getIndexer(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        return response["data"]["getTransactions"].arrayValue
    }

    func fetchBlockTimes(_ heights: [Int64]) async throws -> [Int64: String] {
        let filters: [[String: Any]] = heights.map { ["height": ["eq": $0]] }
        let parameters: Parameters = ["query": GNO_BLOCK_TIME_QUERY, "variables": ["heights": filters]]
        let response = try await AF.request(getIndexer(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value

        var result = [Int64: String]()
        response["data"]["getBlocks"].arrayValue.forEach { block in
            if let height = block["height"].int64 {
                result[height] = block["time"].stringValue
            }
        }
        return result
    }
    
    func simulateTx(_ simulTx: Tm2_Tx_Tx) async throws -> Tm2_Abci_ResponseDeliverTx? {
        let param: Parameters = ["jsonrpc":"2.0",
                                 "method": "abci_query",
                                 "params": [
                                    ".app/simulate",
                                    try simulTx.serializedData().base64EncodedString(),
                                    "0",
                                    false],
                                 "id": 1]
        
        let result = try await AF.request(getRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        
        if let value = result["result"]["response"]["Value"].string {
            return try Tm2_Abci_ResponseDeliverTx.init(serializedBytes: Data(base64Encoded: value)!)
            
        } else {
            return nil
        }
    }
    
    func broadcastTx(_ broadTx: Tm2_Tx_Tx) async throws -> Cosmos_Base_Abci_V1beta1_TxResponse? {
        let params: Parameters = ["jsonrpc":"2.0",
                                  "method": "broadcast_tx_async",
                                  "params": [try broadTx.serializedData().base64EncodedString()],
                                  "id": 1]
        let result = try await AF.request(getRpc(), method: .post, parameters: params, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        let hash = result["result"]["hash"].stringValue
        let log = result["result"]["log"].stringValue
        var response = Cosmos_Base_Abci_V1beta1_TxResponse()
        response.txhash = hash
        response.rawLog = log
        return response
    }
 
    func fetchTx( _ hash: String) async throws -> Cosmos_Tx_V1beta1_GetTxResponse? {
        let param: Parameters = ["method": "tx", "params": [hash], "id" : 1, "jsonrpc" : "2.0"]
        let result = try await AF.request(getRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        
        if !result["error"].isEmpty || !result["result"]["tx_result"]["ResponseBase"]["Error"].isEmpty {
            throw AFError.explicitlyCancelled
        }
        var response = Cosmos_Tx_V1beta1_GetTxResponse()
        var txResponse = Cosmos_Base_Abci_V1beta1_TxResponse()
        txResponse.txhash = result["result"]["hash"].stringValue
        txResponse.code = 0
        txResponse.rawLog = result["result"]["tx_result"]["ResponseBase"]["Log"].stringValue
        response.txResponse = txResponse
        return response
    }
    
    func fetchGrc20Balance(_ tokenInfo: MintscanToken) async {
        let tokenPath = tokenInfo.address!
        let tokenBalancePath = "\(tokenPath).BalanceOf(\"\(chain.bechAddress!)\")"
        
        let param: Parameters = ["method": "abci_query", "params": ["vm/qeval", tokenBalancePath.data(using: .utf8)!.base64EncodedString(), "0", false], "id" : 1, "jsonrpc" : "2.0"]
        let result = try? await AF.request(getRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value

        if let encodedDataString = result?["result"]["response"]["ResponseBase"]["Data"].string {
            let data = Data(base64Encoded: encodedDataString)
            if let balanceString = String(data: data!, encoding: .utf8) {
                let amount = balanceString.components(separatedBy: " ").first?.filter{ $0.isNumber } ?? "0"
                tokenInfo.setAmount(amount)
            }
            
        } else {
            tokenInfo.setAmount("0")
        }
    }
    
    func getRpc() -> String {
        var url = ""
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name) {
            url = endpoint
        } else {
            url = chain.rpcUrl
        }
        if (url.last != "/") {
            return url + "/"
        }
        return url
    }
    
    func getIndexer() -> String {
        return (chain as? ChainGno)?.gnoIndexerUrl ?? ""
    }
}

extension String {
    
    func gnoAmountAndDenom() -> (amount: String, denom: String) {
        let amount = self.filter { $0.isNumber }
        let denom = self.filter { !$0.isNumber }.trimmingCharacters(in: ["\"", " "])
        return (amount.isEmpty ? "0" : amount, denom)
    }
}
