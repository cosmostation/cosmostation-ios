//
//  ChainCanto.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCanto: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Canto"
        tag = "canto60"
        logo1 = "chainCanto"
        logo2 = "chainCanto2"
        apiName = "canto"
        stakeDenom = "acanto"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        accountPrefix = "canto"
        
        grpcHost = "grpc-canto.cosmostation.io"
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
