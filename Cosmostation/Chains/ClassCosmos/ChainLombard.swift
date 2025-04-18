//
//  ChainLombard.swift
//  Cosmostation
//
//  Created by 차소민 on 3/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainLombard: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Lombard"
        tag = "lombard118"
        apiName = "lombard"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ustake"
        bechAccountPrefix = "lom"
        validatorPrefix = "lomvaloper"
        grpcHost = "grpc-lombard.cosmostation.io"
        lcdUrl = "https://lcd-lombard.cosmostation.io/"
    }
}
