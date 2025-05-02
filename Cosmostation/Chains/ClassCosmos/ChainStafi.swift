//
//  ChainStafi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStafi: BaseChain {
    
    override init() {
        super.init()
        
        name = "Stafi"
        tag = "stafi118"
        chainImg = "chainStafi"
        apiName = "stafi"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ufis"
        bechAccountPrefix = "stafi"
        validatorPrefix = "stafivaloper"
        supportStaking = false
        grpcHost = "grpc-stafi.cosmostation.io"
        lcdUrl = "https://lcd-stafi.cosmostation.io/"
    }
}

