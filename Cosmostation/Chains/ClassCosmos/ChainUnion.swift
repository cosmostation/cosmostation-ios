//
//  ChainUnion.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/14/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainUnion: BaseChain {
    
    override init() {
        super.init()
        
        name = "Union"
        tag = "union"
        chainImg = "chainUnion"
        apiName = "union"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "upoa"
        bechAccountPrefix = "union"
        validatorPrefix = "unionvaloper"
        grpcHost = "grpc.rpc-node.union-1.union.build"
        lcdUrl = "https://api.rpc-node.union-1.union.build/"
    }
}
