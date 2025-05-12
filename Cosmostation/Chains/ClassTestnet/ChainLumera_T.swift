//
//  ChainLumera_T.swift
//  Cosmostation
//
//  Created by 차소민 on 5/8/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainLumera_T: ChainLumera {
    override init() {
        super.init()
        
        name = "Lumera Testnet"
        tag = "lumera118_T"
        chainImg = "chainLumera_T"
        isTestnet = true
        apiName = "lumera-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ulume"
        bechAccountPrefix = "lumera"
        validatorPrefix = "lumeravaloper"
        grpcHost = "grpc.testnet.lumera.io"
        lcdUrl = "https://lcd.testnet.lumera.io"
    }
}
