//
//  ChainInitia_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainInitia_T: ChainInitia  {
    
    override init() {
        super.init()
        
        name = "Initia Testnet"
        tag = "initia_T"
        isTestnet = true
        apiName = "initia-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uinit"
        bechAccountPrefix = "init"
        validatorPrefix = "initvaloper"
        grpcHost = "grpc-office-initia-2.cosmostation.io"
        lcdUrl = "https://lcd-office.cosmostation.io/initia-2-testnet/"
    }
}
