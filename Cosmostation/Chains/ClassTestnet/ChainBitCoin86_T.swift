//
//  ChainBitCoin86_T.swift
//  Cosmostation
//
//  Created by 차소민 on 1/21/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation
class ChainBitCoin86_T: ChainBitCoin86 {
    
    override init() {
        super.init()
        
        name = "Bitcoin Signet"
        tag = "bitcoin86_T"
        logo1 = "chainBitcoin_T"
        isTestnet = true
        apiName = "bitcoin-testnet"
        accountKeyType = AccountKeyType(.BTC_Taproot, "m/86'/1'/0'/0/X")
        
        coinSymbol = "sBTC"
        
        mainUrl = "https://rpc-office.cosmostation.io/bitcoin-testnet"
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        mainAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil, "testnet")
    }
}
