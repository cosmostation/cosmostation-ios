//
//  ChainSunrise.swift
//  Cosmostation
//
//  Created by 권혁준 on 9/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSunrise: BaseChain {
    
    override init() {
        super.init()
        
        name = "Sunrise"
        tag = "sunrise118"
        chainImg = "chainSunrise"
        apiName = "sunrise"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uvrise"
        bechAccountPrefix = "sunrise"
        validatorPrefix = "sunrisevaloper"
        grpcHost = "sunrise-grpc.noders.services"
        lcdUrl = "https://sunrise-mainnet-api.mekonglabs.tech/"
    }
}
