//
//  ChainKava60.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava60: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Kava"
        tag = "kava60"
        logo1 = "chainKava"
        logo2 = "chainKava2"
        apiName = "kava"
        stakeDenom = "ukava"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        accountPrefix = "kava"
        
        grpcHost = "grpc-kava.cosmostation.io"
    }
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        let evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        address = KeyFac.convertEvmToBech32(evmAddress, accountPrefix!)
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        let evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        address = KeyFac.convertEvmToBech32(evmAddress, accountPrefix!)
    }
}
