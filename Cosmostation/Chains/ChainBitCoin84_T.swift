//
//  ChainBitCoin84_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBitCoin84_T: BaseChain {
    
    public let pubKeyHash: UInt8 = 111
    public let scriptHash: UInt8 = 196
    public let bech32PrefixPattern: String = "tb"
    
    var btcFetcher: BtcFetcher?
    
    override init() {
        super.init()
        
        name = "BitCoin"
        tag = "bitcoin84_T"
        logo1 = "chainBitcoin"
        isTestnet = true
        apiName = "bitcoin-testnet"
        accountKeyType = AccountKeyType(.BTC_Native_Segwit, "m/84'/1'/0'/0/X")
        
        coinSymbol = "BTC"
        coinLogo = "tokenBtc"
        
        mainUrl = ""
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bech32PrefixPattern, pubKeyHash, scriptHash)
        
        print("ChainBitCoin84_T ", mainAddress)
    }
}
