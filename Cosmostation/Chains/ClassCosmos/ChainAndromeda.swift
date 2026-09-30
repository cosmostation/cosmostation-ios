//
//  ChainAndromeda.swift
//  Cosmostation
//
//  Created by 차소민 on 3/10/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainAndromeda: BaseChain {
    
    override init() {
        super.init()
        
        name = "Andromeda"
        tag = "andromeda118"
        chainImg = "chainAndromeda"
        apiName = "andromeda"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uandr"
        bechAccountPrefix = "andr"
        validatorPrefix = "andrvaloper"
        grpcHost = "grpc-andromeda.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-andromeda.mainnet.cosmoslabs.kr/"
    }
}
