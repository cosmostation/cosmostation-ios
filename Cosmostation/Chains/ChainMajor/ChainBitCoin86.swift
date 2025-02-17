//
//  ChainBitCoin86.swift
//  Cosmostation
//
//  Created by 차소민 on 1/21/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin86: BaseChain {
    
    var btcFetcher: BtcFetcher?

    override init() {
        super.init()
        
        name = "Bitcoin"
        tag = "bitcoin86"
        logo1 = "chainBitcoin"
        apiName = "bitcoin"
        accountKeyType = AccountKeyType(.BTC_Taproot, "m/86'/0'/0'/0/X")
        
        coinSymbol = "BTC"
        coinGeckoId = "bitcoin"
        coinLogo = "tokenBtc"
        
        mainUrl = "https://rpc-office.cosmostation.io/bitcoin-mainnet"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil, "mainnet")
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
    
    func fetchHistory(_ after_txid: String? = nil) {
        Task {
            await getBtcFetcher()?.fetchBtcHistory(after_txid)
            
            getBtcFetcher()?.btcHistory.sort {
                if $0["status"]["confirmed"].boolValue == false {
                    return true
                }
                if $1["status"]["confirmed"].boolValue == false {
                    return false
                }
                return $0["status"]["block_time"].intValue > $1["status"]["block_time"].intValue
            }
            
            DispatchQueue.main.async(execute: {
                NotificationCenter.default.post(name: Notification.Name("fetchHistory"), object: self.tag, userInfo: nil)
            })
        }
    }

}

