//
//  ChainBitCoin84_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin84_T: ChainBitCoin84 {
    
    override init() {
        super.init()
        
        name = "BitCoin Testnet"
        tag = "bitcoin84_T"
        logo1 = "chainBitcoin"
        isTestnet = true
        apiName = "bitcoin-testnet"
        accountKeyType = AccountKeyType(.BTC_Native_Segwit, "m/84'/1'/0'/0/X")
        
        coinSymbol = "BTC"
        coinLogo = "tokenBtc"
        
        pubKeyHash = 111
        scriptHash = 196
        bech32PrefixPattern = "tb"
        
        mainUrl = ""
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bech32PrefixPattern, pubKeyHash, scriptHash)
//        print("ChainBitCoin84_T ", mainAddress)
    }
    
    override func fetchBalances() {
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
                coinsCnt = (btcFetcher.btcBalances == NSDecimalNumber.zero) ? 0 : 1
                
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
}
