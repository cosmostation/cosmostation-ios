//
//  ChainBitCoin49_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin49_T: ChainBitCoin84_T {
    
    override init() {
        super.init()
        
        name = "Bitcoin Signet"
        tag = "bitcoin49_T"
        logo1 = "chainBitcoin_T"
        isDefault = false
        isTestnet = true
        apiName = "bitcoin-testnet"
        accountKeyType = AccountKeyType(.BTC_Nested_Segwit, "m/49'/1'/0'/0/X")
        
        coinSymbol = "BTC"
        coinGeckoId = ""
        coinLogo = "tokenBtc"
        
        mainUrl = "https://rpc-office.cosmostation.io/bitcoin-testnet"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bech32PrefixPattern, pubKeyHash, scriptHash)
//        print("ChainBitCoin49_T ", mainAddress)
    }
}
