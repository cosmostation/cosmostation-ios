//
//  ChainEvmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainEvmos: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Evmos"
        tag = "evmos60"
        logo1 = "chainEvmos"
        logo2 = "chainEvmos2"
        apiName = "evmos"
        stakeDenom = "aevmos"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "evmos"
        validatorPrefix = "evmosvaloper"
        evmCompatible = true
        supportErc20 = true
        
        grpcHost = "grpc-evmos.cosmostation.io"
        rpcURL = "https://rpc-evmos-app.cosmostation.io"
    }
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        evmAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, nil)
        bechAddress = KeyFac.convertEvmToBech32(evmAddress, bechAccountPrefix!)
        if (supportStaking) {
            bechOpAddress = KeyFac.getOpAddressFromAddress(bechAddress, validatorPrefix)
        }
    }
    
}

