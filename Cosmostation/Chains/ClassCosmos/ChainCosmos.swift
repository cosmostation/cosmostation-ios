//
//  ChainCosmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCosmos: BaseChain {
    
    override init() {
        super.init()
        
        name = "Cosmos Hub"
        tag = "cosmos118"
        apiName = "cosmos"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uatom"
        bechAccountPrefix = "cosmos"
        validatorPrefix = "cosmosvaloper"
        grpcHost = "grpc-cosmos.cosmostation.io"
        lcdUrl = "https://lcd-cosmos.cosmostation.io/"
    }
}
