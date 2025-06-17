//
//  ChainKima.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainKima: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Kima Network"
        tag = "kima118"
        chainImg = "chainKima"
        apiName = "kima"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uKIMA"
        bechAccountPrefix = "kima"
        validatorPrefix = "kimavaloper"
        grpcHost = "grpc.kima.network:443"
        lcdUrl = "https://api.kima.network/"
    }
    
}

