//
//  ChainSui.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSui: BaseChain  {
    
    var suiFetcher: SuiFetcher?
    
    override init() {
        super.init()
        
        name = "Sui"
        tag = "suiMainnet"
        logo1 = "chainSui"
        apiName = "sui"
        accountKeyType = AccountKeyType(.SUI_Ed25519, "m/44'/784'/0'/0'/X'")
    
        coinSymbol = "SUI"
        stakeDenom = SUI_MAIN_DENOM
        coinGeckoId = "sui"
        
        mainUrl = "https://sui-mainnet-us-2.cosmostation.io"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
    }
    
    func getSuiFetcher() -> SuiFetcher? {
        if (suiFetcher != nil) { return suiFetcher }
        suiFetcher = SuiFetcher(self)
        return suiFetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            coinsCnt = 0
            let suiResult = await getSuiFetcher()?.fetchSuiBalances()
            
            if (suiResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if (self.fetchState == .Success) {
                if let suiFetcher = getSuiFetcher() {
                    coinsCnt = suiFetcher.suiBalances.count
                }
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchBalances"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    override func fetchData(_ id: Int64) {
        fetchState = .Busy
        Task {
            let suiResult = await getSuiFetcher()?.fetchSuiData(id)
            
            if (suiResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let suiFetcher = getSuiFetcher(), fetchState == .Success {
                print("suiBalances ", suiFetcher.suiBalances.count)
                print("suiStakedList ", suiFetcher.suiStakedList.count)
                print("suiObjects ", suiFetcher.suiObjects.count)
                print("suiBalances ", suiFetcher.suiBalances.count)
                
                coinsCnt = suiFetcher.suiBalances.count
                
                allCoinValue = suiFetcher.allValue()
                allCoinUSDValue = suiFetcher.allValue(true)
                let mainCoinAmount = suiFetcher.allSuiAmount()
                
                allTokenValue = NSDecimalNumber.zero
                allTokenUSDValue = NSDecimalNumber.zero
                
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
    
    
    
}

let SUI_TYPE_COIN = "0x2::coin::Coin"
let SUI_MAIN_DENOM = SUI_TYPE_COIN + "<0x2::sui::SUI>"
