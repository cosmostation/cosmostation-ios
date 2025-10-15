//
//  ChainMantra.swift
//  Cosmostation
//
//  Created by 차소민 on 10/8/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainMantra: BaseChain {
    
    override init() {
        super.init()
        
        name = "Mantra"
        tag = "mantra118"
        chainImg = "chainMantra"
        isDefault = false
        apiName = "mantra"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uom"
        bechAccountPrefix = "mantra"
        validatorPrefix = "mantravaloper"
        grpcHost = "grpc-mantra.cosmostation.io"
        lcdUrl = "https://lcd-mantra.cosmostation.io/"
    }
}
