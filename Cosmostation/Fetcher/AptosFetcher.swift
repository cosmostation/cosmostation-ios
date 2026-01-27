//
//  AptosFetcher.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/3/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import AptosKit
import Alamofire
import SwiftyJSON
import CryptoKit

class AptosFetcher {
    
    var chain: BaseChain!
    
    var aptosAssetBalance = [current_fungible_asset_balances]()
    var moveHistory = [JSON]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchAptosData() async -> Swift.Bool {
        aptosAssetBalance.removeAll()
        
        do {
            if let accountCoinInfo = try await fetchAccountCoinInfo() {
                accountCoinInfo.forEach { asset in
                    if let _ = BaseData.instance.getAsset(chain.apiName, asset.asset_type) {
                        aptosAssetBalance.append(asset)
                    }
                }
                return true
            }
            return false
            
        } catch {
            return false
        }
    }
    
    func fetchMoveHistory() async {
        moveHistory.removeAll()
        
        if let history = try? await fetchTxHistory() {
            let reversed = Array((history ?? []).reversed())
            moveHistory = reversed
        }
    }
    
    func client() -> Aptos? {
        if (chain as! ChainAptos).isValidFullnodeURL(getApi()), (chain as! ChainAptos).isValidIndexerGraphQLURL(getGraphQL()) {
            let settings = AptosSettings(
                network: nil,
                fullNode: getApi(),
                faucet: nil,
                indexer: getGraphQL(),
                client: nil,
                clientConfig: ClientConfig.Companion.shared.default_,
                fullNodeConfig: nil,
                indexerConfig: nil,
                faucetConfig: nil
            )
            let config = AptosConfig(settings: settings)
            return Aptos(config: config, graceFull: false)
            
        } else {
            return nil
        }
    }
    
    func accountAddress() -> AccountAddress {
        return AccountAddress.companion.fromString(input: chain.mainAddress)
    }
    
    func allAssetValue(_ usd: Swift.Bool? = false) -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if aptosAssetBalance.isEmpty {
            return sum
        }
        aptosAssetBalance.forEach { asset in
            sum = sum.adding(balanceValue(asset.asset_type, usd))
        }
        
        return sum
    }
    
    func balanceAmount(_ assetType: String?) -> NSDecimalNumber {
        if aptosAssetBalance.isEmpty {
            return NSDecimalNumber.zero
        }
        
        if let asset = aptosAssetBalance.filter({ $0.asset_type == assetType}).first {
            return NSDecimalNumber(string: asset.amount?.stringValue)
        }
        return NSDecimalNumber.zero
    }
    
    func balanceValue(_ assetType: String?, _ usd: Swift.Bool? = false) -> NSDecimalNumber {
        if (balanceAmount(assetType).compare(NSDecimalNumber.zero).rawValue <= 0) { return NSDecimalNumber.zero }
        if let msAsset = BaseData.instance.getAsset(chain.apiName, assetType) {
            let msPrice = BaseData.instance.getPrice(msAsset.coinGeckoId, usd)
            return msPrice.multiplying(by: balanceAmount(assetType)).multiplying(byPowerOf10: -msAsset.decimals!, withBehavior: handler6)
        }
        return NSDecimalNumber.zero
    }
    
    func valueCoinCnt() -> Int {
        return aptosAssetBalance.count
    }
    
    func hasFee() -> Swift.Bool {
        let aptosBalance = balanceAmount(APTOS_MAIN_DENOM)
        return aptosBalance.compare(APTOS_DEFAULT_FEE).rawValue > 0
    }
    
    func getApi() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_LCD_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.apiUrl
    }
    
    func getGraphQL() -> String {
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_RPC_ENDPOINT +  " : " + chain.name) {
            return endpoint.trimmingCharacters(in: .whitespaces)
        }
        return chain.mainUrl
    }
}

extension AptosFetcher {
    
    // account coin info
    @MainActor
    func fetchAccountCoinInfo() async throws -> [current_fungible_asset_balances]? {
        guard let client = client() else { return nil }
        
        let coinData = try await client.getAccountCoinsData(accountAddress: accountAddress(), minimumLedgerVersion: nil)
        
        if coinData is OptionSome {
            return (coinData as? OptionSome)?.value?.current_fungible_asset_balances
        } else {
            return nil
        }
    }
    
    // account history info
    func fetchTxHistory() async throws -> [JSON]? {
        let url = getApi() + "accounts/" + chain.mainAddress + "/transactions?limit=50"
        return try? await AF.request(url, method: .get).serializingDecodable([JSON].self).value
    }
    
    // simulate
    @MainActor
    func fetchSimulateTransaction(_ to: String, _ toSendDenom: String, _ toAmount: String) async throws -> [JSON]? {
        guard let client = client() else { return nil }
        guard let msAsset = BaseData.instance.getAsset(chain.apiName, toSendDenom) else { return nil }
        
        let url = "\(getApi())transactions/simulate"
        
        let accountInfo = try await client.getAccountInfo(accountAddress: accountAddress()) { _ in }
        let gasPriceInfo = try await client.getGasPriceEstimation()
        
        if accountInfo is OptionSome {
            let sequenceNumber = (accountInfo as? OptionSome)?.value?.sequenceNumber ?? "0"
            let nowMillis = Int64(Date().timeIntervalSince1970 * 1000)
            let expirationTimestampSecs = nowMillis / 1000 + Int64(20)
            let dummySig = Data(repeating: 0, count: 64).toHexString()
            
            let payload: Payload
            if msAsset.type == "fungible" {
                payload = Payload(
                    function: FUNGIBLE_FUNCTION_TYPE,
                    type_arguments: ["0x1::fungible_asset::Metadata"],
                    arguments: [toSendDenom, to, toAmount])
            } else {
                payload = Payload(type_arguments: [toSendDenom], arguments: [to, toAmount])
            }
            let signature = Signature(public_key: chain.publicKey?.toHexString(), signature: dummySig)
            
            let encodeRequest = EncodeRequest(
                sender: chain.mainAddress,
                sequence_number: String(sequenceNumber),
                max_gas_amount: String(1000),
                gas_unit_price: String(gasPriceInfo.gasEstimate),
                expiration_timestamp_secs: String(expirationTimestampSecs),
                payload: payload,
                signature: signature)
            
            let simulation = try? await AF.request(url, method: .post,
                                                   parameters: encodeRequest,
                                                   encoder: JSONParameterEncoder.default,
                                                   headers: [:]).validate().serializingDecodable([JSON].self).value
            
            return simulation
            
        } else {
            return nil
        }
    }
    
    @MainActor
    func fetchEncodeSubmission(_ to: String, _ toSendDenom: String, _ toAmount: String, _ maxGasAmount: String) async throws -> (String, String)? {
        guard let client = client() else { return nil }
        guard let msAsset = BaseData.instance.getAsset(chain.apiName, toSendDenom) else { return nil }
        
        let url = "\(getApi())transactions/encode_submission"
        
        let accountInfo = try await client.getAccountInfo(accountAddress: accountAddress()) { _ in }
        let gasPriceInfo = try await client.getGasPriceEstimation()
        
        if accountInfo is OptionSome {
            let sequenceNumber = (accountInfo as? OptionSome)?.value?.sequenceNumber ?? "0"
            let nowMillis = Int64(Date().timeIntervalSince1970 * 1000)
            let expirationTimestampSecs = nowMillis / 1000 + Int64(20)
            
            let payload: Payload
            if msAsset.type == "fungible" {
                payload = Payload(
                    function: FUNGIBLE_FUNCTION_TYPE,
                    type_arguments: ["0x1::fungible_asset::Metadata"],
                    arguments: [toSendDenom, to, toAmount])
            } else {
                payload = Payload(type_arguments: [toSendDenom], arguments: [to, toAmount])
            }
            
            let encodeRequest = EncodeRequest(
                sender: chain.mainAddress,
                sequence_number: String(sequenceNumber),
                max_gas_amount: maxGasAmount,
                gas_unit_price: String(gasPriceInfo.gasEstimate),
                expiration_timestamp_secs: String(expirationTimestampSecs),
                payload: payload)
            
            let encodeSubmission = try? await AF.request(url, method: .post,
                                             parameters: encodeRequest,
                                             encoder: JSONParameterEncoder.default,
                                             headers: [:]).validate().serializingDecodable(String.self).value
            
            return (encodeSubmission ?? "", String(expirationTimestampSecs))
            
        } else {
            return nil
        }
    }
    
    // broadcast
    @MainActor
    func fetchSubmitTransaction(_ signatureHex: String, _ to: String, _ toSendDenom: String, _ toAmount: String, _ maxGasAmount: String, _ expirationTimestampSecs: String) async throws -> String? {
        guard let client = client() else { return nil }
        guard let msAsset = BaseData.instance.getAsset(chain.apiName, toSendDenom) else { return nil }
        
        let url = "\(getApi())transactions"
        
        let accountInfo = try await client.getAccountInfo(accountAddress: accountAddress()) { _ in }
        let gasPriceInfo = try await client.getGasPriceEstimation()
        
        if accountInfo is OptionSome {
            let sequenceNumber = (accountInfo as? OptionSome)?.value?.sequenceNumber ?? "0"
            
            let payload: Payload
            if msAsset.type == "fungible" {
                payload = Payload(
                    function: FUNGIBLE_FUNCTION_TYPE,
                    type_arguments: ["0x1::fungible_asset::Metadata"],
                    arguments: [toSendDenom, to, toAmount])
            } else {
                payload = Payload(type_arguments: [toSendDenom], arguments: [to, toAmount])
            }
            let signature = Signature(public_key: chain.publicKey?.toHexString(), signature: signatureHex)
            
            let encodeRequest = EncodeRequest(
                sender: chain.mainAddress,
                sequence_number: String(sequenceNumber),
                max_gas_amount: maxGasAmount,
                gas_unit_price: String(gasPriceInfo.gasEstimate),
                expiration_timestamp_secs: expirationTimestampSecs,
                payload: payload,
                signature: signature)
            
            let submitTransaction = try? await AF.request(url, method: .post,
                                                   parameters: encodeRequest,
                                                   encoder: JSONParameterEncoder.default,
                                                   headers: [:]).validate().serializingDecodable(JSON.self).value
            
            return submitTransaction?["hash"].stringValue
            
        } else {
            return nil
        }
    }
    
    // dapp function
    func signMessage(_ param: JSON?, _ dAppUrl: String?) async throws -> String? {
        let privateKey = chain.privateKey?.hexEncodedString()
        let messageJson = AptosJS.shared.callJSValue(key: "signAptosMessage", param: [privateKey, param?.rawValue, chain.mainAddress, dAppUrl])
        return messageJson
    }
    
    func originalTx(_ serializedTxHex: String) async throws -> String? {
        let tx = AptosJS.shared.callJSValue(key: "getOriginalTx", param: [serializedTxHex])
        return tx
    }
    
    func signTx(_ serializedTxHex: String) async throws -> String? {
        let privateKey = chain.privateKey?.hexEncodedString() ?? ""
        let result: String? = try await withCheckedThrowingContinuation { continuation in
                AptosJS.shared.callJSValueAsync(
                    key: "signAptosTx",
                    param: [serializedTxHex, privateKey, getApi()]
                ) { value, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let value = value else {
                        continuation.resume(returning: nil)
                        return
                    }
                    continuation.resume(returning: value)
                }
            }
        
        return result
    }
}

extension AptosFetcher {
    
    struct EncodeRequest: Encodable {
        let sender: String?
        let sequence_number: String?
        let max_gas_amount: String?
        let gas_unit_price: String?
        let expiration_timestamp_secs: String?
        let payload: Payload?
        var signature: Signature? = nil
    }
    
    struct Payload: Encodable {
        let type: String = "entry_function_payload"
        var function: String? = DEFAULT_FUNCTION_TYPE
        let type_arguments: [String]
        let arguments: [String]
    }
    
    struct Signature: Encodable {
        let type: String = "ed25519_signature"
        let public_key: String?
        let signature: String
    }
    
    func sign(_ message: Foundation.Data) async throws -> Foundation.Data {
        let signing = try Curve25519.Signing.PrivateKey(rawRepresentation: chain?.privateKey ?? Data())
        let sign = try signing.signature(for: message)
        return sign
    }
}

let DEFAULT_FUNCTION_TYPE = "0x1::aptos_account::transfer_coins"

let FUNGIBLE_FUNCTION_TYPE = "0x1::primary_fungible_store::transfer"
