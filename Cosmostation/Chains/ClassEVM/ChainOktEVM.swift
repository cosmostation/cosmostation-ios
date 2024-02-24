//
//  ChainOktEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainOktEVM: EvmClass  {
    
    override init() {
        super.init()
        
        name = "OKT"
        tag = "okt60_Keccak"
        logo1 = "chainOkt"
        logo2 = "chainOkt2"
        apiName = "okc"
        
        coinSymbol = "OKT"
        coinGeckoId = "oec-token"
        coinLogo = "tokenOkt"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "ex"                                                                    //only case
        supportStaking = false
        
        rpcURL = "https://exchainrpc.okex.org"
        explorerURL = "https://www.oklink.com/oktc/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
        
    }
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)                     //only case
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)                     //only case
    }
    
}
