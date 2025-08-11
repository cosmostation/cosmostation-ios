//
//  SolanaFetcher.swift
//  Cosmostation
//
//  Created by 권혁준 on 7/7/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SolanaFetcher {
    
    var chain: BaseChain!
    
    var solanaAccountInfo = JSON()
    var solanaTokenInfo = [(String, JSON)]()
    
    var mintscanSplTokens = [MintscanToken]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchSolanaBalance() async -> Bool {
        solanaAccountInfo = JSON()
        if let accountInfo = try? await fetchAccountInfo(chain.mainAddress) {
            guard let result = accountInfo?["result"], result.exists() else {
                return false
            }
            solanaAccountInfo = result
            return true
        }
        return true
    }
    
    func fetchSolanaData(_ id: Int64) async -> Bool {
        mintscanSplTokens.removeAll()
        solanaAccountInfo = JSON()
        solanaTokenInfo.removeAll()
        
        do {
            if let accountInfo = try await fetchAccountInfo(chain.mainAddress),
               let tokenInfo = try await fetchTokenInfo(chain.mainAddress) {
                
                self.mintscanSplTokens = BaseData.instance.mintscanSplTokens?.filter({ $0.chainName == chain.apiName }) ?? []
                
                if (accountInfo["result"].exists() && tokenInfo["result"].exists()) {
                    solanaAccountInfo = accountInfo["result"]
                    tokenInfo["result"]["value"].arrayValue.forEach{ tokenValue in
                        let info = tokenValue["account"]["data"]["parsed"]["info"]
                        let pubKey = tokenValue["pubkey"].stringValue
                        
                        solanaTokenInfo.append((pubKey, info))
                    }
                    
                    solanaTokenInfo.forEach { tokenInfo in
                        let mintAddress = tokenInfo.1["mint"].stringValue
                        let amount = tokenInfo.1["tokenAmount"]["amount"].stringValue
                        
                        if let splToken = self.mintscanSplTokens.filter({ $0.address?.lowercased() == mintAddress.lowercased() }).first {
                            splToken.type = "spl"
                            splToken.setAmount(amount)
                        }
                    }
                    return true
                    
                } else {
                    return false
                }
            }
            return true
            
        } catch {
            print("solana error \(error) ", chain.tag)
            return false
        }
    }
    
    func getSolanaRpc() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.mainUrl
    }
}


extension SolanaFetcher {
    
    func fetchAccountInfo(_ address: String) async throws -> JSON? {
        let params: Any = [address, ["encoding": "base58"]]
        let parameters: Parameters = ["method": "getAccountInfo", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchTokenInfo(_ address: String) async throws -> JSON? {
        let params: Any = [address, ["programId": SOLANA_PROGRAM_ID], ["encoding": "jsonParsed"]]
        let parameters: Parameters = ["method": "getTokenAccountsByOwner", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func balanceAmount() -> NSDecimalNumber {
        return NSDecimalNumber(value: solanaAccountInfo["value"]["lamports"].uInt64Value)
    }

    func balanceValue(usd: Bool? = false) -> NSDecimalNumber {
        let amount = balanceAmount()
        if (amount == NSDecimalNumber.zero) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.coinSymbol) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: amount).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        return balanceValue(usd: usd).adding(allTokenValue(usd))
    }
    
    func splTokenValue(_ mintAddress: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let splToken = mintscanSplTokens.filter({ $0.address == mintAddress }).first {
            let msPrice = BaseData.instance.getPrice(splToken.coinGeckoId, usd)
            return msPrice.multiplying(by: splToken.getAmount()).multiplying(byPowerOf10: -splToken.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        
        solanaTokenInfo.forEach { info in
            if let splToken = mintscanSplTokens.filter({ $0.address == info.1["mint"].stringValue }).first {
                let msPrice = BaseData.instance.getPrice(splToken.coinGeckoId, usd)
                let value = msPrice.multiplying(by: splToken.getAmount()).multiplying(byPowerOf10: -splToken.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
        }
        return result
    }
    
    func valueCoinCnt() -> Int {
        return (balanceAmount() == NSDecimalNumber.zero) ? 0 : 1
    }
    
    func valueTokenCnt(_ id: Int64) -> Int {
        return solanaTokenInfo.count
    }
}
