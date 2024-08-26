//
//  ChainBitCoin84.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin84: BaseChain {
    
    var pubKeyHash: UInt8 = 0
    var scriptHash: UInt8 = 5
    var bech32PrefixPattern: String = "bc"
    var btcFetcher: BtcFetcher?
    
    override init() {
        super.init()
        
        name = "BitCoin"
        tag = "bitcoin84"
        logo1 = "chainBitcoin"
        apiName = "bitcoin"
        accountKeyType = AccountKeyType(.BTC_Native_Segwit, "m/84'/0'/0'/0/X")
        
        coinSymbol = "BTC"
        coinGeckoId = "bitcoin"
        coinLogo = "tokenBtc"
        
        mainUrl = ""
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bech32PrefixPattern, pubKeyHash, scriptHash)
//        print("ChainBitCoin84 ", mainAddress)
    }
    
    func getBtcFetcher() -> BtcFetcher? {
        if (btcFetcher != nil) { return btcFetcher }
        btcFetcher = BtcFetcher(self)
        return btcFetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            let btcResult = await getBtcFetcher()?.fetchBtcBalances()
            
            if (btcResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if (self.fetchState == .Success) {
                if let btcFetcher = getBtcFetcher() {
                    coinsCnt = (btcFetcher.btcBalances == NSDecimalNumber.zero && btcFetcher.btcPendingInput == NSDecimalNumber.zero) ? 0 : 1
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
            let btcResult = await getBtcFetcher()?.fetchBtcData(id)
            
            if (btcResult == false) {
                fetchState = .Fail
            } else {
                fetchState = .Success
            }
            
            if let btcFetcher = getBtcFetcher(), fetchState == .Success {
                coinsCnt = (btcFetcher.btcBalances == NSDecimalNumber.zero && btcFetcher.btcPendingInput == NSDecimalNumber.zero) ? 0 : 1
                
                allCoinValue = btcFetcher.allValue()
                allCoinUSDValue = btcFetcher.allValue(true)
                allTokenValue = NSDecimalNumber.zero
                allTokenUSDValue = NSDecimalNumber.zero
                
                BaseData.instance.updateRefAddressesValue(
                    RefAddress(id, self.tag, self.mainAddress, "",
                               btcFetcher.btcBalances.stringValue, allCoinUSDValue.stringValue, allTokenUSDValue.stringValue,
                               coinsCnt))
            }
            
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("FetchData"), object: self.tag, userInfo: nil)
            })
        }
    }
    
    func fetchHistory() {
        Task {
            await getBtcFetcher()?.fetchBtcHistory()
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchHistory"), object: self.tag, userInfo: nil)
            })
        }
    }
}
