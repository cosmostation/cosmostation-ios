//
//  ChainArkeo.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/16/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainArkeo: BaseChain {
    
    override init() {
        super.init()
        
        name = "Arkeo"
        tag = "arkeo118"
        chainImg = "chainArkeo"
        apiName = "arkeo"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uarkeo"
        bechAccountPrefix = "arkeo"
        validatorPrefix = "arkeovaloper"
        grpcHost = "grpc.arkeo.nodestake.org"
        lcdUrl = "https://rest-seed.arkeo.network/"
    }
    
}
