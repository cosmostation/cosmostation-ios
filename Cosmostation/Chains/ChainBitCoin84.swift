//
//  ChainBitCoin84.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin84: BaseChain {
    
    public let pubKeyHash: UInt8 = 0
    public let scriptHash: UInt8 = 5
    public let bech32PrefixPattern: String = "bc"
    
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
        
        print("ChainBitCoin84 ", mainAddress)
    }
    
    func getBtcFetcher() -> BtcFetcher? {
        if (btcFetcher != nil) { return btcFetcher }
        btcFetcher = BtcFetcher(self)
        return btcFetcher
    }
    
    override func fetchBalances() {
        fetchState = .Busy
        Task {
            
        }
    }
}
