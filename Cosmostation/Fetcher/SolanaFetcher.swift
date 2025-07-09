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
    var solanaTokenInfo = [JSON]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchSolanaBalance() async -> Bool {
        solanaAccountInfo = JSON()
        if let balance = try? await fetchAccountInfo(chain.mainAddress) {
            
        }
        return true
    }
    
    func fetchSolanaData(_ id: Int64) async -> Bool {
        solanaAccountInfo = JSON()
        solanaTokenInfo.removeAll()
        
        do {
            if let accountInfo = try await fetchAccountInfo(chain.mainAddress),
               let tokenInfo = try await fetchTokenInfo(chain.mainAddress) {
                
                if (accountInfo["result"].exists() && tokenInfo["result"].exists()) {
                    solanaAccountInfo = accountInfo["result"]
                    tokenInfo["result"]["value"].arrayValue.forEach({ token in
                        solanaTokenInfo.append(token)
                    })
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
        return balanceValue(usd: usd)
    }
    
    func allTokenValue(_ id: Int64, _ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        
//        mintscanErc20Tokens.filter({ $0.wallet_preload == true }).forEach { tokenInfo in
//            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
//            let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
//            result = result.adding(value)
//        }
        return result
    }
    
    func valueCoinCnt() -> Int {
        return 1
//        return gnoBalances?.filter({ BaseData.instance.getAsset(chain.apiName, $0.denom) != nil }).count ?? 0
    }
    
    func valueTokenCnt(_ id: Int64) -> Int {
        return solanaTokenInfo.count
    }
}
