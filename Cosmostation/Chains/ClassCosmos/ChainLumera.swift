//
//  ChainLumera.swift
//  Cosmostation
//
//  Created by 차소민 on 5/7/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainLumera: BaseChain {
    override init() {
        super.init()
        
        name = "Lumera"
        tag = "lumera118"
        chainImg = "chainLumera"
        apiName = "lumera"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ulume"
        bechAccountPrefix = "lumera"
        validatorPrefix = "lumeravaloper"
        grpcHost = "grpc.lumera.io"
        lcdUrl = "https://lcd.lumera.io"
    }
}
