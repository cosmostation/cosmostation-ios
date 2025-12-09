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

class AptosFetcher {
    
    var chain: BaseChain!
    
    var aptosAssetBalance = [current_fungible_asset_balances]()
    var moveHistory = [JSON]()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchAptosBalance() async -> Swift.Bool {
        return true
    }
    
    func fetchAptosData(_ id: Int64) async -> Swift.Bool {
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
            print("aptos error \(error) ", chain.tag)
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
    
    func account() -> AccountAddress {
        return AccountAddress.companion.fromString(input: chain.mainAddress)
    }
    
    func allAssetValue(_ usd: Swift.Bool? = false) -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if aptosAssetBalance.isEmpty {
            return sum
        }
        aptosAssetBalance.forEach { asset in
            sum = sum.adding(balanceValue(asset.asset_type))
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
        if let endpoint = UserDefaults.standard.string(forKey: KEY_CHAIN_EVM_RPC_ENDPOINT +  " : " + chain.name) {
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
        
        let coinData = try await client.getAccountCoinsData(accountAddress: account(), minimumLedgerVersion: nil)
        
        if coinData is OptionSome {
            return (coinData as? OptionSome)?.value?.current_fungible_asset_balances
        } else {
            return nil
        }
    }
    
    func fetchTxHistory() async throws -> [JSON]? {
        let url = getApi() + "accounts/" + chain.mainAddress + "/transactions?limit=50"
        return try? await AF.request(url, method: .get).serializingDecodable([JSON].self).value
    }
}

extension AptosFetcher {
    
    func toKotlinByteArray(_ data: Foundation.Data) -> KotlinByteArray {
        let kba = KotlinByteArray(size: Int32(data.count))
        data.enumerated().forEach { (i, byte) in
            kba.set(index: Int32(i), value: Int8(bitPattern: byte))
        }
        return kba
    }
}
