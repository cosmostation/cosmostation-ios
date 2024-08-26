//
//  ChainBitCoin49.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin49: ChainBitCoin84 {
    
    override init() {
        super.init()
        
        name = "BitCoin"
        tag = "bitcoin49"
        logo1 = "chainBitcoin"
        isDefault = false
        apiName = "bitcoin"
        accountKeyType = AccountKeyType(.BTC_Nested_Segwit, "m/49'/0'/0'/0/X")
        
        coinSymbol = "BTC"
        coinGeckoId = "bitcoin"
        coinLogo = "tokenBtc"
        
        mainUrl = ""
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bech32PrefixPattern, pubKeyHash, scriptHash)
//        print("ChainBitCoin49 ", mainAddress)
    }
    
}
