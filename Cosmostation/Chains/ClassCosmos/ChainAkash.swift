//
//  File.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainAkash: BaseChain {
    
    override init() {
        super.init()
        
        name = "Akash"
        tag = "akash118"
        chainImg = "chainAkash"
        apiName = "akash"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uakt"
        bechAccountPrefix = "akash"
        validatorPrefix = "akashvaloper"
        grpcHost = "grpc-akash.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-akash.mainnet.cosmoslabs.kr/"
    }
    
}
