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
    
    var mintscanSplTokens = [MintscanToken]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchSolanaBalance() async -> Bool {
        solanaAccountInfo = JSON()
        if let accountInfo = try? await fetchAccountInfo(chain.mainAddress, "base58") {
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
            if let accountInfo = try await fetchAccountInfo(chain.mainAddress, "base58"),
               let tokenInfo = try await fetchTokenInfo(chain.mainAddress) {
                
                self.mintscanSplTokens = BaseData.instance.mintscanSplTokens?.filter({ $0.chainName == chain.apiName }) ?? []
                
                if (accountInfo["result"].exists() && tokenInfo["result"].exists()) {
                    solanaAccountInfo = accountInfo["result"]
                    tokenInfo["result"]["value"].arrayValue.forEach{ tokenValue in
                        let info = tokenValue["account"]["data"]["parsed"]["info"]
                        let mint = info["mint"].stringValue
                        let amount = info["tokenAmount"]["amount"].stringValue
                        
                        if let _ = BaseData.instance.getToken(chain.apiName, mint) {
                            if NSDecimalNumber(string: amount).compare(NSDecimalNumber.zero).rawValue > 0 {
                                solanaTokenInfo.append(info)
                            }
                        }
                    }
                    
                    solanaTokenInfo.forEach { tokenInfo in
                        let mintAddress = tokenInfo["mint"].stringValue
                        let amount = tokenInfo["tokenAmount"]["amount"].stringValue
                        
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
            if let splToken = mintscanSplTokens.filter({ $0.address == info["mint"].stringValue }).first {
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
    
    func getSolanaRpc() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.mainUrl
    }
}


extension SolanaFetcher {
    
    // account & sol info
    func fetchAccountInfo(_ address: String, _ addressType: String) async throws -> JSON? {
        let params: Any = [address, ["encoding": addressType]]
        let parameters: Parameters = ["method": "getAccountInfo", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    // spl info
    func fetchTokenInfo(_ address: String) async throws -> JSON? {
        let params: Any = [address, ["programId": SOLANA_PROGRAM_ID], ["encoding": "jsonParsed"]]
        let parameters: Parameters = ["method": "getTokenAccountsByOwner", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    // rent balance
    func fetchMinimumRentBalanceInfo(_ dataSize: Int) async throws -> JSON? {
        let params: Any = [dataSize, ["commitment": "finalized"]]
        let parameters: Parameters = ["method": "getMinimumBalanceForRentExemption", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchLatestBlockHash() async throws -> String? {
        let params: Any = [["commitment": "finalized"]]
        let parameters: Parameters = ["method": "getLatestBlockhash", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        let result = try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value["result"]
        return result["value"]["blockhash"].stringValue
    }
    
    // sol send Tx
    func createTransferTransaction(_ from: String, _ to: String, _ toAmount: String, _ recentBlockHash: String?) async throws -> String? {
        let createTransactionHex = SolanaJS.shared.callJSValue(key: "createTransferTransactionWithSerialize", param: [from, to, toAmount, recentBlockHash])
        return createTransactionHex
    }
    
    // spl send Tx
    func createSplTokenTransferTransaction(_ from: String, _ to: String, _ mint: String, _ toAmount: String, _ recentBlockHash: String?, _ isCreateATA: Bool) async throws -> String? {
        let createSplTokenTransactionHex = SolanaJS.shared.callJSValue(key: "createSplTokenTransferTransactionWithSerialize", param: [from, to, mint, toAmount, recentBlockHash, isCreateATA])
        return createSplTokenTransactionHex
    }
    
    func fetchSimulate(_ txBase64: String) async throws -> JSON? {
        let params: Any = [txBase64, ["commitment": "confirmed", "encoding": "base64", "replaceRecentBlockhash": true]]
        let parameters: Parameters = ["method": "simulateTransaction", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchFeeMessage(_ txMessageBase64: String) async throws -> JSON? {
        let params: Any = [txMessageBase64, ["commitment": "processed"]]
        let parameters: Parameters = ["method": "getFeeForMessage", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchPrioritizationFee() async throws -> JSON? {
        let params: Any = [[chain.mainAddress]]
        let parameters: Parameters = ["method": "getRecentPrioritizationFees", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    // Set baseFee + tip
    func overwriteComputeBudgetProgram(_ txBase64: String, _ computeUnitLimit: UInt64, _ computeUnitPrice: Double) async throws -> String {
        let overwriteProgramTxHex = """
        function overwriteComputeBudgetProgramFunction() {
            const txBase64 = '\(txBase64)';
            const computeUnitLimit = \(computeUnitLimit);
            const computeUnitPrice = \(computeUnitPrice);
            
            const programTx = overwriteComputeBudgetProgram(txBase64, {
                units: computeUnitLimit,
                microLamports: Math.ceil(computeUnitPrice * 1000000)
            });
            return programTx;
        };
        """
        
        return SolanaJS.shared.overwriteProgramTx(overwriteProgramTxHex)
    }
    
    func signTransaction(_ programTxHex: String) async throws -> String? {
        let privateKey = chain.privateKey?.hexEncodedString()
        let signTransactionHex = SolanaJS.shared.callJSValue(key: "signTransaction", param: [programTxHex, privateKey])
        return signTransactionHex
    }
    
    func fetchSendTransaction(_ txHex: String) async throws -> JSON? {
        let params: Any = [txHex, ["encoding": "base64"]]
        let parameters: Parameters = ["method": "sendTransaction", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    // TxHash
    func fetchTxStatusInfo(_ txHash: String) async throws -> JSON? {
        let params: Any = [[txHash], ["searchTransactionHistory": true]]
        let parameters: Parameters = ["method": "getSignatureStatuses", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func associatedTokenAddress(_ mint: String, _ to: String) async throws -> String? {
        let receiverATA = SolanaJS.shared.callJSValue(key: "getAssociatedTokenAddress", param: [mint, to])
        return receiverATA
    }
    
    func parseMessage(_ params: JSON) async throws -> String? {
        let message = params["message"].stringValue
        return SolanaJS.shared.callJSValue(key: "parseMessage", param: [message])
    }
    
    func signMessage(_ params: JSON) async throws -> String? {
        let message = params["message"].stringValue
        let privateKey = chain.privateKey?.hexEncodedString()
        return SolanaJS.shared.callJSValue(key: "signMessage", param: [message, privateKey])
    }
    
    func parseInstructionsFromTx(_ serializedTx: String) async throws -> String? {
        return SolanaJS.shared.callJSValue(key: "parseInstructionsFromTx", param: [serializedTx])
    }
    
    func accountsToTrack(_ serializedTx: String) async throws -> String? {
        return SolanaJS.shared.callJSValue(key: "getAccountsToTrack", param: [serializedTx, chain.mainAddress])
    }
    
    func serializedTxMessageFromTx(_ serializedTx: String) async throws -> String? {
        return SolanaJS.shared.callJSValue(key: "getSerializedTxMessageFromTx", param: [serializedTx])
    }
    
    func simulateValue(_ serializedTx: String, _ accountList: [String]) async throws -> JSON {
        let params: Any = [serializedTx, ["commitment": "confirmed", "encoding": "base64", "replaceRecentBlockhash": true, "accounts": ["encoding": "base64", "addresses": accountList]]]
        let parameters: Parameters = ["method": "simulateTransaction", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        let simulate = try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        return simulate["result"]["value"]
    }
    
    func multiAccountsValue(_ accountList: [String]) async throws -> [JSON] {
        let params: Any = [accountList, ["encoding": "base64", "commitment": "finalized"]]
        let parameters: Parameters = ["method": "getMultipleAccounts", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        let multiAccounts = try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        return multiAccounts["result"]["value"].arrayValue
    }
    
    func analyzeTokenChanges(_ accounts: String, _ multiAccounts: String?, _ simulateValue: String?) async throws -> String? {
        return SolanaJS.shared.callJSValue(key: "analyzeTokenChanges", param: [chain.mainAddress, accounts, multiAccounts, simulateValue])
    }
    
    func fetchDappSendTransaction(_ txHex: String, _ requestToSign: JSON?) async throws -> JSON? {
        let skipPreflight = requestToSign?["skipPreflight"].boolValue ?? false
        let preflightCommitment = requestToSign?["preflightCommitment"].stringValue ?? "finalized"
        let maxRetries = requestToSign?["maxRetries"].int64Value ?? 0
        let minContextSlot = requestToSign?["minContextSlot"].int64Value ?? 0
        
        let params: Any = [txHex, ["encoding": "base64", "skipPreflight": skipPreflight, "preflightCommitment": preflightCommitment, "maxRetries": maxRetries, "minContextSlot": minContextSlot]]
        let parameters: Parameters = ["method": "sendTransaction", "params": params , "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getSolanaRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
}
