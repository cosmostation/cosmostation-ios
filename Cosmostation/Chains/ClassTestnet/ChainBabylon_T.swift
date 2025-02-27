//
//  ChainBabylon_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/8/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBabylon_T: ChainBabylon {
    
    override init() {
        super.init()
        
        name = "Babylon Testnet"
        tag = "babylon118_T"
        logo1 = "chainBabylon_T"
        isTestnet = true
        apiName = "babylon-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ubbn"
        bechAccountPrefix = "bbn"
        validatorPrefix = "bbnvaloper"
        grpcHost = "grpc-office-babylon.cosmostation.io"
        lcdUrl = "https://lcd-office.cosmostation.io/babylon-testnet/"
    }
    
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        privateKey = KeyFac.getPriKeyFromSeed(accountKeyType.pubkeyType, seed, getHDPath(lastPath))
        btcPriKey = KeyFac.getPriKeyFromSeed(.BTC_Taproot, seed, "m/86'/1'/0'/0/X".replacingOccurrences(of: "X", with: lastPath))
        setInfoWithPrivateKey(privateKey!)
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        btcPubKey = KeyFac.getPubKeyFromPrivateKey(btcPriKey ?? privateKey!, .BTC_Taproot)?.toHexString()
        bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
        mainAddress = KeyFac.getAddressFromPubKey(Data(hex: btcPubKey!), .BTC_Taproot,  nil, "testnet")
    }
}
