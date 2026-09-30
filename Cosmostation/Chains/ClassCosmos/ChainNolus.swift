//
//  ChainNolus.swift
//  Cosmostation
//
//  Created by 차소민 on 11/11/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainNolus: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Nolus"
        tag = "nolus118"
        chainImg = "chainNolus"
        apiName = "nolus"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "unls"
        bechAccountPrefix = "nolus"
        validatorPrefix = "nolusvaloper"
        grpcHost = "grpc-nolus.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-nolus.mainnet.cosmoslabs.kr/"
    }
}

