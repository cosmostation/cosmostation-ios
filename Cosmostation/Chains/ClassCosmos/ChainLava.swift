//
//  ChainLava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/13/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainLava: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Lava"
        tag = "lava118"
        logo1 = "chainLava"
        apiName = "lava"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ulava"
        bechAccountPrefix = "lava@"
        validatorPrefix = "lava@valoper"
        grpcHost = "grpc-lava.cosmostation.io"
        lcdUrl = "https://lcd-lava.cosmostation.io/"
    }
    
}
