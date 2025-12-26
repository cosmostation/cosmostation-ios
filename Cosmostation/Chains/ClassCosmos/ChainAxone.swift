//
//  ChainAxone.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainAxone: BaseChain {
    
    override init() {
        super.init()
        
        name = "Axone"
        tag = "axone118"
        chainImg = "chainAxone"
        apiName = "axone"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uaxone"
        bechAccountPrefix = "axone"
        validatorPrefix = "axonevaloper"
        grpcHost = "grpc.axone.cumulo.com.es"
        lcdUrl = "https://api.axone.citizenweb3.com/"
    }
}
