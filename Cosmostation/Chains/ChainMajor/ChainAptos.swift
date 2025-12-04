//
//  ChainAptos.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/2/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainAptos: BaseChain  {
    
    var aptosfetcher: AptosFetcher?
    
    override init() {
        super.init()
        
        name = "Aptos"
        tag = "aptosMainnet"
        chainImg = "chainAptos"
        apiName = "aptos"
        accountKeyType = AccountKeyType(.APTOS_ED25519, "m/44'/637'/0'/0'/X'")
    
        coinSymbol = "APT"
        stakeDenom = APTOS_MAIN_DENOM
        
        apiUrl = "https://api.mainnet.aptoslabs.com/v1/"
        mainUrl = "https://api.mainnet.aptoslabs.com/v1/graphql"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    func getAptosFetcher() -> AptosFetcher? {
        if (aptosfetcher != nil) { return aptosfetcher }
        aptosfetcher = AptosFetcher(self)
        return aptosfetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            coinsCnt = 0 
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchBalances"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task { @MainActor in
            let aptosResult = await getAptosFetcher()?.fetchAptosData(id)
            
            if (aptosResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let aptosFetcher = getAptosFetcher(), fetchState == .Success {
                coinsCnt = aptosFetcher.valueCoinCnt()
                allCoinValue = aptosFetcher.allAssetValue()
                allCoinUSDValue = aptosFetcher.allAssetValue(true)
                allTokenValue = NSDecimalNumber.zero
                allTokenUSDValue = NSDecimalNumber.zero
                let mainCoinAmount = aptosFetcher.balanceAmount(APTOS_MAIN_DENOM)
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.mainAddress, "",
                               mainCoinAmount.stringValue, allCoinUSDValue.stringValue, allTokenUSDValue.stringValue,
                               coinsCnt))
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func isValidFullnodeURL(_ fullnode: String) -> Bool {
        guard let url = URL(string: fullnode), let scheme = url.scheme, (scheme == "http" || scheme == "https") else { return false }
        let trimmed = fullnode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.hasSuffix("v1")
    }
    
    func isValidIndexerGraphQLURL(_ indexer: String) -> Bool {
        guard let url = URL(string: indexer), let scheme = url.scheme, (scheme == "http" || scheme == "https") else { return false }
        let trimmed = indexer.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return trimmed.hasSuffix("v1/graphql")
    }
}

let APTOS_MAIN_DENOM = "0x1::aptos_coin::AptosCoin"

let APTOS_DEFAULT_FEE = NSDecimalNumber.init(string: "5000")
