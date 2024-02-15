//
//  ChainAlthea60.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/05.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAlthea60: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Althea"
        tag = "althea60"
        logo1 = "chainAlthea"
        logo2 = "chainAlthea2"
        apiName = "althea"
        stakeDenom = "ualtg"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "althea"
        validatorPrefix = "altheavaloper"
        evmCompatible = true
        
//        grpcHost = "grpc-kava.cosmostation.io"
//        rpcURL = "https://rpc-kava-app.cosmostation.io"
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
