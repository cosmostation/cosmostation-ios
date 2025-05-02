//
//  ChainInt3face.swift
//  Cosmostation
//
//  Created by 차소민 on 3/12/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainInt3face: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Int3face"
        tag = "int3face118"
        chainImg = "chainInt3face"
        apiName = "int3face"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uint3"
        bechAccountPrefix = "int3"
        validatorPrefix = "int3valoper"
        grpcHost = "grpc.mainnet.int3face.zone"
        lcdUrl = "https://api.mainnet.int3face.zone/"
    }
}
