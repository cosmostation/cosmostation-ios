//
//  ChainGgez.swift
//  Cosmostation
//
//  Created by 차소민 on 2/5/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainGgez: BaseChain {
    
    override init() {
        super.init()
        
        name = "GGEZ1 Chain"
        tag = "ggez118"
        chainImg = "chainGgez"
        apiName = "ggezchain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uggez1"
        bechAccountPrefix = "ggez"
        validatorPrefix = "ggezvaloper"
        grpcHost = "grpc.ggez.one:4443"
        lcdUrl = "https://rest.ggez.one/"
    }
}
