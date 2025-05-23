//
//  ChainPaloma.swift
//  Cosmostation
//
//  Created by 차소민 on 3/12/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainPaloma: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Paloma"
        tag = "paloma118"
        chainImg = "chainPaloma"
        apiName = "paloma"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ugrain"
        bechAccountPrefix = "paloma"
        validatorPrefix = "palomavaloper"
        grpcHost = "paloma.grpc.kjnodes.com"
        lcdUrl = "https://api-1.paloma.nodes.guru/"
    }
}
