//
//  ChainLum118.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainLum118: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Lum"
        tag = "lum118"
        chainImg = "chainLum"
        isDefault = false
        apiName = "lum"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ulum"
        bechAccountPrefix = "lum"
        validatorPrefix = "lumvaloper"
        grpcHost = "lum-grpc.stakerhouse.com"
        lcdUrl = "https://lum.api.m.stavr.tech/"
    }
    
}
