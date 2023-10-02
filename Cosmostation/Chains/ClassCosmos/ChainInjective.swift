//
//  ChainInjective.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainInjective: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Injective"
        tag = "injective60"
        logo1 = "chainInjective"
        logo2 = "chainInjective2"
        apiName = "injective"
        stakeDenom = "inj"
        
        accountKeyType = AccountKeyType(.INJECTIVE_Secp256k1, "m/44'/60'/0'/0/X")
        accountPrefix = "inj"
        
        grpcHost = "grpc-injective.cosmostation.io"
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
