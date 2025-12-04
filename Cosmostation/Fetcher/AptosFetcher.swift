//
//  AptosFetcher.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/3/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
import AptosKit

class AptosFetcher {
    
    var chain: BaseChain!
    
    var aptosAssetBalance = [current_fungible_asset_balances]()
    
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
                print("Test12345 : ", accountCoinInfo)
                return true
            }
            return false
            
        } catch {
            print("aptos error \(error) ", chain.tag)
            return false
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
}
