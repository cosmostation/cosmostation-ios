//
//  BtcFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class BtcFetcher {
    
    var chain: BaseChain!
    
    var btcBalances = NSDecimalNumber.zero
    var btcPendingInput = NSDecimalNumber.zero
    var btcPendingOutput = NSDecimalNumber.zero
    var btcBlockHeight: UInt64?
    var btcHistory = [JSON]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchBtcBalances() async -> Bool {
        if let stats = try? await fetchBalance() {
            guard let addresss = stats?["address"].string, addresss == chain.mainAddress else {
                return false
            }
            let chain_funded_txo_sum = NSDecimalNumber(value: stats?["chain_stats"]["funded_txo_sum"].uInt64Value ?? 0)
            let chain_spent_txo_sum = NSDecimalNumber(value: stats?["chain_stats"]["spent_txo_sum"].uInt64Value ?? 0)
            let mempool_funded_txo_sum = NSDecimalNumber(value: stats?["mempool_stats"]["funded_txo_sum"].uInt64Value ?? 0)
            let mempool_spent_txo_sum = NSDecimalNumber(value: stats?["mempool_stats"]["spent_txo_sum"].uInt64Value ?? 0)
            
            btcBalances = chain_funded_txo_sum.subtracting(chain_spent_txo_sum).subtracting(mempool_spent_txo_sum)
            btcPendingInput = mempool_funded_txo_sum
            btcPendingOutput = mempool_spent_txo_sum
        }
        return true
    }
    
    func fetchBtcData(_ id: Int64) async -> Bool {
        btcBalances = NSDecimalNumber.zero
        btcPendingInput  = NSDecimalNumber.zero
        btcPendingOutput = NSDecimalNumber.zero
        do {
            if let stats = try await fetchBalance() {
//                print("stats ", stats)
                guard let addresss = stats["address"].string, addresss == chain.mainAddress else {
                    print("fetchBtc error no address")
                    return false
                }
                let chain_funded_txo_sum = NSDecimalNumber(value: stats["chain_stats"]["funded_txo_sum"].uInt64Value)
                let chain_spent_txo_sum = NSDecimalNumber(value: stats["chain_stats"]["spent_txo_sum"].uInt64Value)
                let mempool_funded_txo_sum = NSDecimalNumber(value: stats["mempool_stats"]["funded_txo_sum"].uInt64Value)
                let mempool_spent_txo_sum = NSDecimalNumber(value: stats["mempool_stats"]["spent_txo_sum"].uInt64Value)
                
                btcBalances = chain_funded_txo_sum.subtracting(chain_spent_txo_sum).subtracting(mempool_spent_txo_sum)
                btcPendingInput = mempool_funded_txo_sum
                btcPendingOutput = mempool_spent_txo_sum
                
                print("", chain.mainAddress, "   ", btcBalances)
            }
            return true
            
        } catch {
            print("fetchBtc error \(error) ", chain.tag)
            return false
        }
    }
    
    func fetchBtcHistory() async {
        btcHistory.removeAll()
        btcBlockHeight = nil
        if let histroy = try? await fetchTxHistory(),
           let height = try? await fetchBlockHeight() {
            btcHistory.append(contentsOf: histroy ?? [])
            btcBlockHeight = height
        }
        return
    }
    
    
    func allValue(_ usd: Bool? = false) -> NSDecimalNumber {
        let msPrice = BaseData.instance.getPrice(chain.coinGeckoId, usd)
        return (btcBalances.adding(btcPendingInput)).multiplying(by: msPrice).multiplying(byPowerOf10: -8, withBehavior: handler6)
    }
    
    
    func mempoolUrl() -> String {
        if (chain.isTestnet) {
//            return "https://mempool.space/signet"
            return "https://mempool.space/testnet4"
        }
        return "https://mempool.space"
    }
    
    func getBtcRpc() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.mainUrl
    }

}




extension BtcFetcher {
    
    func fetchBalance() async throws -> JSON? {
        let url = mempoolUrl() + "/api/address/" + chain.mainAddress
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchUtxos() async throws -> [JSON]? {
        let url = mempoolUrl() + "/api/address/" + chain.mainAddress + "/utxo"
        return try? await AF.request(url, method: .get).serializingDecodable([JSON].self).value
    }
    
    func fetchTxHistory() async throws -> [JSON]? {
        let url = mempoolUrl() + "/api/address/" + chain.mainAddress + "/txs"
        return try? await AF.request(url, method: .get).serializingDecodable([JSON].self).value
    }
    
    func fetchMempool() async throws -> [JSON]? {
        let url = mempoolUrl() + "/api/address/" + chain.mainAddress + "/txs/mempool"
        return try? await AF.request(url, method: .get).serializingDecodable([JSON].self).value
    }
    
    func fetchTxChain() async throws -> [JSON]? {
        let url = mempoolUrl() + "/api/address/" + chain.mainAddress + "/txs/chain"
        return try? await AF.request(url, method: .get).serializingDecodable([JSON].self).value
    }
    
    func fetchTx(_ hex: String) async throws -> JSON? {
        let url = mempoolUrl() + "/api/tx/" + hex
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    

    
    func fetchBlockHeight() async throws -> UInt64? {
        let url = mempoolUrl() + "/api/blocks/tip/height"
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value.uInt64Value
    }
    
    func fetchFee() async throws -> JSON? {
        let url = mempoolUrl() + "/api/v1/fees/recommended"
        return try? await AF.request(url, method: .get).serializingDecodable(JSON.self).value
    }
    
    func fetchEstimatesmartfee() async throws -> JSON {
        let parameters: Parameters = ["jsonrpc": "2.0",
                                      "id": 1,
                                      "method": "estimatesmartfee",
                                      "params": [2]]
        return try await AF.request(getBtcRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func fetchGetrawtransaction(_ utxo: JSON) async throws -> JSON {
        let parameters: Parameters = ["jsonrpc": "2.0",
                                      "id": 1,
                                      "method": "getrawtransaction",
                                      "params": [utxo["txid"].stringValue,
                                                 false,
                                                 utxo["status"]["block_hash"].stringValue]]
        return try await AF.request(getBtcRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func sendRawtransaction(_ txHex: String) async throws -> JSON {
        let parameters: Parameters = ["jsonrpc": "2.0",
                                      "id": 1,
                                      "method": "sendrawtransaction",
                                      "params": [txHex]]
        return try await AF.request(getBtcRpc(), method: .post, parameters: parameters, encoding: JSONEncoding.default).serializingDecodable(JSON.self).value
    }
    
    func initFee() async throws -> Int? {
        if let utxos = try await fetchUtxos()?.filter({ $0["status"]["confirmed"].boolValue }) {
            do {
                let type = BtcTxType.init(rawValue: chain.accountKeyType.pubkeyType.algorhythm!)!
                let vbyte = (type.vbyte.overhead) + (type.vbyte.inputs * utxos.count) + (type.vbyte.output * 2)
                let estimatesmartfee = try await fetchEstimatesmartfee()
                let feeRate = estimatesmartfee["result"]["feerate"].doubleValue
                
                if let error = estimatesmartfee["error"].string {
                    print("Fail fetch estimatesmartfee", error)
                    
                    return nil
                }
                return Int(ceil(Double(vbyte) * feeRate * 100000))
                
            } catch {
                print("Fail fetch fee rate", error)
                return nil
            }
        } else {
            return nil
        }
    }
    

    func getTxString(_ utxo: [JSON], _ fromChain: BaseChain, _ receiver: String, _ toAmount: NSDecimalNumber, _ fee: UInt64, _ memo: String?) async -> String {
        
        var inputs = ""
        var outputs = ""
        
        var allValue = 0
        
        let sender = fromChain.mainAddress
        let publicKey = fromChain.publicKey!.toHexString()
        let privateKey = fromChain.privateKey!.toHexString()
        let network = fromChain.apiName.contains("testnet") ? "testnet" : "bitcoin" //
        guard let type = BtcTxType(rawValue: fromChain.accountKeyType.pubkeyType.algorhythm!) else {
            return "undefined"
        }
        

        for utxo in utxo {
            
            switch type {
                
            case .p2wpkh:
                inputs += """
                            {
                            hash: '\(utxo["txid"])',
                            index: \(utxo["vout"]),
                            witnessUtxo: {
                                script: senderPayment.output,
                                value: \(utxo["value"])
                                }
                            },
                        """
                
            case .p2pkh:
                do {
                    if let result = try await fetchGetrawtransaction(utxo)["result"].string {
                        inputs += """
                            {
                              hash: '\(utxo["txid"])',
                              index: \(utxo["vout"]),
                              nonWitnessUtxo: aTb('\(result)'),
                            },
                        """
                    }
                } catch {
                    print("Fail getRawTransaction", error)
                }
                
                
            case .p2sh:
                inputs += """
                            {
                                hash: '\(utxo["txid"])',
                                index: \(utxo["vout"]),
                                redeemScript: senderPayment.redeem.output,
                                witnessUtxo: {
                                  script: senderPayment.output,
                                  value: \(utxo["value"]),
                                },
                            },
                        """
                
            }
                    
            allValue += utxo["value"].intValue
        }
        
        if let memo {
            outputs = """
                        {
                            address: '\(receiver)',
                            value: \(toAmount),
                        },
                        {
                            address: '\(sender)',
                            value: \(allValue) - \(toAmount) - \(fee),
                        },
                      
                        m('\(memo)')
                      
                      """

        } else {
            outputs = """
                        {
                            address: '\(receiver)',
                            value: \(toAmount),
                        },
                        {
                            address: '\(sender)',
                            value: \(allValue) - \(toAmount) - \(fee),
                        },
                      """
        }
        
        let createTxString = """
            function result() {
        
               const privateKey = '\(privateKey)';
               const publicKey = '\(publicKey)';
               const type = '\(type.rawValue)';
               const network = '\(network)';
        
               const senderPayment = getPayment(publicKey, type, network);

               const inputs = [
                 \(inputs)
               ];
        
               const outputs = [
                 \(outputs)
               ];
        
               const txHex = createTx(inputs, outputs, privateKey, network);
        
               return txHex;
           };
        """
        print(createTxString)

        return createTxString

    }


}
