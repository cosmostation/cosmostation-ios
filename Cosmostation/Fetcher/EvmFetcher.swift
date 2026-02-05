//
//  EvmFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import BigInt
import web3swift
import Web3Core

class EvmFetcher {
    
    var chain: BaseChain!
    
    var evmBalances = NSDecimalNumber.zero
    var mintscanErc20Tokens = [MintscanToken]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    
    func fetchEvmBalances() async -> Bool {
        evmBalances = NSDecimalNumber.zero
        if let balanceJson = try? await fetchEvmBalance(chain.evmAddress!),
           let balance = balanceJson?["result"].string?.hexToNSDecimal() {
            self.evmBalances = balance
        } else {
            return false
        }
        return true
    }
    
    func fetchEvmData(_ id: Int64) async -> Bool {
        mintscanErc20Tokens.removeAll()
        
        do {
            let balanceJson = try await fetchEvmBalance(self.chain.evmAddress!)
            if let balance = balanceJson?["result"].string?.hexToNSDecimal() {
                self.evmBalances = balance
            } else {
                return false
            }
            
            self.mintscanErc20Tokens = BaseData.instance.mintscanErc20Tokens?.filter({ $0.chainName == chain.apiName }).map { token in
                return token.copy() as! MintscanToken
            } ?? []
            
            if chain.isSupportMultiCall() && !chain.evmMultiCallAddress().isEmpty {
                await self.fetchMulticallErc20Balance(self.chain.evmAddress, mintscanErc20Tokens)
                
            } else {
                let userDisplaytoken = BaseData.instance.getDisplayErc20s(id, self.chain.tag)
                
                await mintscanErc20Tokens.concurrentForEach { erc20 in
                    if (userDisplaytoken == nil) {
                        if (erc20.wallet_preload == true) {
                            await self.fetchErc20BalanceOf(self.chain.evmAddress, erc20)
                        }
                        
                    } else {
                        if (userDisplaytoken?.contains(erc20.address!) == true) {
                            await self.fetchErc20BalanceOf(self.chain.evmAddress, erc20)
                        }
                    }
                }
            }
            
            return true
            
        } catch {
            print("evm error \(error) ", chain.tag)
            return false
        }
    }
    
    func allCoinValue(_ usd: Bool? = false) -> NSDecimalNumber {
        if let msAsset = BaseData.instance.getAsset(chain.apiName, chain.gasAssetDenom()) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return evmBalances.multiplying(by: msPrice).multiplying(byPowerOf10: -18, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func tokenValue(_ address: String, _ usd: Bool? = false) -> NSDecimalNumber {
        if let tokenInfo = mintscanErc20Tokens.filter({ $0.address == address }).first {
            let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
            return msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func allTokenValue(_ id: Int64, _ usd: Bool? = false) -> NSDecimalNumber {
        var result = NSDecimalNumber.zero
        
        if let tokens = BaseData.instance.getDisplayErc20s(id, chain.tag) {
            mintscanErc20Tokens.filter({ tokens.contains($0.address ?? "") }).forEach { tokenInfo in
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
            
        } else {
            mintscanErc20Tokens.filter({ $0.wallet_preload == true }).forEach { tokenInfo in
                let msPrice = BaseData.instance.getPrice(tokenInfo.coinGeckoId, usd)
                let value = msPrice.multiplying(by: tokenInfo.getAmount()).multiplying(byPowerOf10: -tokenInfo.decimals!, withBehavior: handler6)
                result = result.adding(value)
            }
            
        }
        return result
    }
    
    func valueCoinCnt() -> Int {
        return evmBalances != NSDecimalNumber.zero ? 1 : 0
    }
    
    func valueTokenCnt(_ id: Int64) -> Int {
        if let tokens = BaseData.instance.getDisplayErc20s(id, chain.tag) {
            return tokens.count
            
        } else {
            return mintscanErc20Tokens.filter({ $0.getAmount() != NSDecimalNumber.zero }).count
        }
    }
    
}

//about mintscan api
extension EvmFetcher {
    
    func fetchEvmBalance(_ address: String) async throws -> JSON? {
        let param: Parameters = ["method": "eth_getBalance", "params": [address, "latest"], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchErc20BalanceOf(_ evmAddress: String?, _ tokenInfo: MintscanToken) async {
        guard let url = URL(string: getEvmRpc()),
              let web3Provider = try? await Web3HttpProvider.init(url: url, network: .Custom(networkID: chain.chainIdEvmBigint))
        else { return }
        
        let web3 = Web3.init(provider: web3Provider)
        
        if let tokenAddress = EthereumAddress(tokenInfo.address ?? ""),
           let accountAddress = EthereumAddress(evmAddress ?? "") {
            let erc20 = ERC20BalanceOf(web3: web3, contractAddress: tokenAddress)
            let balanceOf = try? erc20.balanceOf(accountAddress)
            
            let response = try? await balanceOf?.callContractMethod()
            let reponseParse: [String: Any] = (response ?? nil) ?? [:]

            let balance = (reponseParse["balance"] as? BigUInt) ?? (reponseParse["0"] as? BigUInt)
            let erc20Balance = balance?.hexString.hexToNSDecimal()
            tokenInfo.setAmount(erc20Balance?.stringValue ?? "")
        }
    }
    
    func fetchErc20BalanceAmount(_ contractAddress: String) async throws -> NSDecimalNumber? {
        guard let url = URL(string: getEvmRpc()),
              let web3Provider = try? await Web3HttpProvider.init(url: url, network: .Custom(networkID: chain.chainIdEvmBigint))
        else { return nil }
        
        let web3 = Web3.init(provider: web3Provider)
        if let tokenAddress = EthereumAddress(contractAddress),
           let accountAddress = EthereumAddress(self.chain.evmAddress ?? "") {
            let erc20 = ERC20BalanceOf(web3: web3, contractAddress: tokenAddress)
            let balanceOf = try? erc20.balanceOf(accountAddress)
            
            let response = try? await balanceOf?.callContractMethod()
            let reponseParse: [String: Any] = (response ?? nil) ?? [:]
            
            let balance = (reponseParse["balance"] as? BigUInt) ?? (reponseParse["0"] as? BigUInt)
            return balance?.hexString.hexToNSDecimal()
        }
        return nil
    }
    
    func fetchMulticallErc20Balance(_ evmAddress: String?, _ erc20Tokens: [MintscanToken]) async {
        guard let url = URL(string: getEvmRpc()),
              let web3Provider = try? await Web3HttpProvider.init(url: url, network: .Custom(networkID: chain.chainIdEvmBigint))
        else { return }
        
        let web3 = Web3.init(provider: web3Provider)
        
        // multicall params
        var calls: [[AnyObject]] = []
        var validTokens: [String] = []
        calls.reserveCapacity(erc20Tokens.count)
        validTokens.reserveCapacity(erc20Tokens.count)
        
        guard let accountAddress = EthereumAddress(evmAddress ?? ""),
              let multiCallAddress = EthereumAddress(chain.evmMultiCallAddress())
        else { return }
        let accountData = try? balanceOfCalldata(accountAddress)
        
        // setting params
        for token in erc20Tokens {
            guard let tokenStr = token.address?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                  !tokenStr.isEmpty,
                  let tokenAddress = EthereumAddress(tokenStr) else { continue }
            
            calls.append([tokenAddress as AnyObject, true as AnyObject, accountData as AnyObject])
            validTokens.append(token.address?.lowercased() ?? "")
        }
        
        guard !calls.isEmpty else { return }
        
        let multicall = MulticallContract(web3: web3, contractAddress: multiCallAddress)
        guard let aggregate = try? multicall.aggregate3Op(calls: calls) else { return }
        
        // eth_call
        let callContract = try? await aggregate.callContractMethod()
        guard let response = callContract ?? nil else { return }
        guard let rawResponse = (response["0"] ?? response["returnData"]) as? [[Any]] else { return }
        
        var balances: [String: BigUInt] = [:]
        balances.reserveCapacity(validTokens.count)
        
        // multicall parsing
        for (i, tuple) in rawResponse.enumerated() {
            guard i < validTokens.count, tuple.count >= 2 else { continue }
            
            let isSuccess = tuple[0] as? Bool ?? false
            let dataResponse = tuple[1] as? Data
            
            if isSuccess, let bytes = dataResponse {
                let decodeValue = bytes.count >= 32 ? BigUInt(bytes.suffix(32)) : BigUInt(bytes)
                balances[validTokens[i]] = decodeValue
                
            } else {
                balances[validTokens[i]] = 0
            }
        }
        
        for i in erc20Tokens.indices {
            guard let addr = erc20Tokens[i].address?.lowercased(), !addr.isEmpty else { continue }
            let bal = balances[addr] ?? 0
            erc20Tokens[i].setAmount(bal.description)
            
            let contractAddress = erc20Tokens[i].address?.lowercased() ?? ""
            let balance = balances[contractAddress]
            erc20Tokens[i].setAmount(balance?.description ?? "0")
        }
    }
    
    func fetchEvmTxReceipt(_ txHash: String) async throws -> JSON? {
        let param: Parameters = ["method": "eth_getTransactionReceipt", "params": [txHash], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchEvmTxByHash(_ txHash: String) async throws -> JSON? {
        let param: Parameters = ["method": "eth_getTransactionByHash", "params": [txHash], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchEvmEstimateGas(_ reqParam: JSON) async throws -> JSON? {
        let param: Parameters = ["method": "eth_estimateGas", "params": [reqParam.dictionaryObject], "id" : 1, "jsonrpc" : "2.0"]
        let response = try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
        return response
    }
    
    func fetchEvmBlockNumbers() async throws -> JSON? {
        let param: Parameters = ["method": "eth_blockNumber", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
     
    func fetchEvmEthCall(_ reqParam: JSON) async throws -> JSON? {
        let param: Parameters = ["method": "eth_call", "params": [reqParam.dictionaryObject, "latest"], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchEvmBlockByNumber() async throws -> JSON? {
        let param: Parameters = ["method": "eth_getBlockByNumber", "params": ["latest", false], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchEvmGasPrice() async throws -> JSON? {
        let param: Parameters = ["method": "eth_gasPrice", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchEvmMaxPriorityFeePerGas() async throws -> JSON? {
        let param: Parameters = ["method": "eth_maxPriorityFeePerGas", "params": [], "id" : 1, "jsonrpc" : "2.0"]
        return try await AF.request(getEvmRpc(), method: .post, parameters: param, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func getEvmRpc() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_EVM_RPC_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.evmRpcURL
    }
    
}



let EVM_BASE_FEE = NSDecimalNumber.init(string: "588000000000000")
