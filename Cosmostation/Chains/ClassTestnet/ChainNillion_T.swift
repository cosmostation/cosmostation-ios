//
//  ChainNillion_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainNillion_T: ChainNillion {
    
    override init() {
        super.init()
        
        name = "Nillion Testnet"
        tag = "nillion118_T"
        chainImg = "chainNillion_T"
        isTestnet = true
        apiName = "nillion-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "unil"
        bechAccountPrefix = "nillion"
        validatorPrefix = "nillionvaloper"
        grpcHost = "grpc-office-nillion.cosmostation.io"
        lcdUrl = "https://testnet-nillion-api.lavenderfive.com/"
    }
}
