//
//  ChainAllora.swift
//  Cosmostation
//
//  Created by 차소민 on 2/5/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainAllora: BaseChain {
    
    override init() {
        super.init()
        
        name = "Allora"
        tag = "allora118"
        apiName = "allora"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uallo"
        bechAccountPrefix = "allo"
        validatorPrefix = "allovaloper"
        grpcHost = "allora-grpc.mainnet.allora.network"
        lcdUrl = "https://allora-api.mainnet.allora.network/"
    }
    
}
