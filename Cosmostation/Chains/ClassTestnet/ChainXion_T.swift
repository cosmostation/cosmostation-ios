//
//  ChainXion_T.swift
//  Cosmostation
//
//  Created by 차소민 on 2/6/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainXion_T: ChainXion {
    
    override init() {
        super.init()
        
        name = "Xion Testnet"
        tag = "xion118_T"
        chainImg = "chainXion_T"
        isTestnet = true
        apiName = "xion-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uxion"
        bechAccountPrefix = "xion"
        validatorPrefix = "xionvaloper"
        grpcHost = "grpc-office-xion.cosmostation.io"
        lcdUrl = "https://lcd-office.cosmostation.io/xion-testnet/"
    }

}
