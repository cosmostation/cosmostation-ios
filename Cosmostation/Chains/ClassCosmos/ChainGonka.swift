//
//  ChainGonka.swift
//  Cosmostation
//
//  Created by yongjoo jung on 12/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainGonka: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Gonka"
        tag = "gonka1200"
        chainImg = "chainGonka"
        apiName = "gonka"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/1200'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ngonka"
        bechAccountPrefix = "gonka"
        validatorPrefix = "gonkavaloper"
        grpcHost = "gonka04.6block.com:8443"
        lcdUrl = "https://node1.gonka.ai:8443/chain-api/"
    }
}
