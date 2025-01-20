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
        
        name = "Bitcoin Signet"
        tag = "bitcoin84_T"
        logo1 = "chainBitcoin_T"
        isTestnet = true
        apiName = "bitcoin-testnet"
        accountKeyType = AccountKeyType(.BTC_Native_Segwit, "m/84'/1'/0'/0/X")
        
        coinSymbol = "sBTC"
        coinGeckoId = ""
        coinLogo = "tokenBtc_signet"
        
        pubKeyHash = 111
        scriptHash = 196
        bech32PrefixPattern = "tb"
        
        mainUrl = "https://rpc-office.cosmostation.io/bitcoin-testnet"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bech32PrefixPattern, pubKeyHash, scriptHash)
//        print("ChainBitCoin84_T ", mainAddress)
    }
}
