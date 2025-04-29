//
//  ChainBitCoin84.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin84: ChainBitCoin86 {
    
    override init() {
        super.init()
        
        name = "Bitcoin"
        tag = "bitcoin84"
        isDefault = false
        apiName = "bitcoin"
        accountKeyType = AccountKeyType(.BTC_Native_Segwit, "m/84'/0'/0'/0/X")
        
        coinSymbol = "BTC"
        
        mainUrl = "https://rpc-office.cosmostation.io/bitcoin-mainnet"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil, "mainnet")
//        print("ChainBitCoin84 ", mainAddress)
    }
}
