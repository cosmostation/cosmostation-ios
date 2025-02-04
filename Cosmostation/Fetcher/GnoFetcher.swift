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
    
    var gnoAccountNumber: UInt64?
    var gnoSequenceNum: UInt64?
    var gnoBalances: [Cosmos_Base_V1beta1_Coin]?
    
    var mintscanGrc20Tokens = [MintscanToken]()

    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    
    func fetchGnoBalances() async -> Bool {
        gnoBalances = [Cosmos_Base_V1beta1_Coin]()
        if let _ = try? await fetchAuth(),
           let balance = try? await fetchBalance() {
            self.gnoBalances = balance
        }
        return true
    }
    
    
    func fetchGnoData(_ id: Int64) async -> Bool {
        
        mintscanGrc20Tokens.removeAll()
        gnoBalances = nil
        do {
            if let grc20Tokens = try? await fetchGrc20Info(),
               let balance = try await fetchBalance(),
               let _ = try? await fetchAuth() {
                
                self.mintscanGrc20Tokens = grc20Tokens
                self.gnoBalances = balance
                let userDisplayGrc20token = BaseData.instance.getDisplayGrc20s(id, self.chain.tag)
                await mintscanGrc20Tokens.concurrentForEach { grc20 in
                    if (userDisplayGrc20token == nil) {
                        if (grc20.wallet_preload == true) {
                            await self.fetchGrc20Balance(grc20)
                        }
                    } else {
                        if (userDisplayGrc20token?.contains(grc20.contract!) == true) {
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

    func denomValue(_ denom: String, _ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValue(denom, usd)
    }
    
    func allStakingDenomAmount() -> NSDecimalNumber {
        return balanceAmount(chain.stakeDenom!)
    }

    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValueSum(usd)
    }
    
    func valueCoinCnt() -> Int {
        return gnoBalances?.filter({ BaseData.instance.getAsset(chain.apiName, $0.denom) != nil }).count ?? 0
    }
    
    func valueTokenCnt() -> Int {
            return mintscanGrc20Tokens.filter({ $0.getAmount() != NSDecimalNumber.zero }).count
    }
}


extension GnoFetcher {
    
    func tokenValue(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if chain.isSupportGrc20() {
            if let tokenInfo = mintscanGrc20Tokens.filter({ $0.contract == address }).first {
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                if msPrice != 0 {
                    return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                }
            }
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        
        if chain.isSupportGrc20() {
            mintscanGrc20Tokens.forEach { tokenInfo in
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                if msPrice != 0 {
                    let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                    result = result.adding(value)
                }
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
}


extension GnoFetcher {
    func fetchGrc20Info() async throws -> [MintscanToken] {
        if (!chain.isSupportGrc20()) { return [] }
         
        let result = try await AF.request(BaseNetWork.msGrc20InfoUrl(chain.apiName), method: .get).serializingDecodable([MintscanToken].self).value
        return result
    }
}


extension GnoFetcher {
    func fetchAuth() async throws {
        gnoAccountNumber = nil
        gnoSequenceNum = nil
        
        let params: Parameters = ["jsonrpc":"2.0",
                                  "method": "abci_query",
                                  "params": ["auth/accounts/\(chain.bechAddress!)", "", "0", false],
                                  "id": 1]
        let response = try await AF.request(getRpc(), method: .post, parameters: params, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        let encodedDataString = response["result"]["response"]["ResponseBase"]["Data"].stringValue
        let data = Data(base64Encoded: encodedDataString)
        if String(data: data!, encoding: .utf8) == "null" {
            return
        }
        let jsonData = try JSON(data: data!)
        gnoAccountNumber = jsonData["BaseAccount"]["account_number"].uInt64Value
        gnoSequenceNum = jsonData["BaseAccount"]["sequence"].uInt64Value
    }
    
    func fetchBalance() async throws -> [Cosmos_Base_V1beta1_Coin]? {
        let params: Parameters = ["jsonrpc":"2.0",
                                  "method": "abci_query",
                                  "params": ["bank/balances/\(chain.bechAddress!)", "", "0", false],
                                  "id": 1]
        let response = try await AF.request(getRpc(), method: .post, parameters: params, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        let encodedDataString = response["result"]["response"]["ResponseBase"]["Data"].stringValue
        
        let data = Data(base64Encoded: encodedDataString)
        let coins = String(data: data!, encoding: .utf8) ?? ""
        if coins.isEmpty {
            return []
        }
        
        let amount = coins.filter { $0.isNumber }
        let denom = coins.filter { !$0.isNumber }.trimmingCharacters(in: ["\""])
        
        return [Cosmos_Base_V1beta1_Coin.init(denom, amount)]
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
        let tokenPath = tokenInfo.contract!
        let tokenBalancePath = "\(tokenPath).BalanceOf(\"\(chain.bechAddress!)\")"
        
        let param: Parameters = ["method": "abci_query", "params": ["vm/qeval", tokenBalancePath.data(using: .utf8)!.base64EncodedString(),"0",false], "id" : 1, "jsonrpc" : "2.0"]
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
}
