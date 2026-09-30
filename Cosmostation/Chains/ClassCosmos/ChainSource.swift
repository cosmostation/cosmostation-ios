//
//  ChainSource.swift
//  Cosmostation
//
//  Created by 차소민 on 10/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainSource: BaseChain {
    
    override init() {
        super.init()
        
        name = "Source"
        tag = "source118"
        chainImg = "chainSource"
        apiName = "source"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "usource"
        bechAccountPrefix = "source"
        validatorPrefix = "sourcevaloper"
        grpcHost = "grpc-source.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-source.mainnet.cosmoslabs.kr/"
    }
}
