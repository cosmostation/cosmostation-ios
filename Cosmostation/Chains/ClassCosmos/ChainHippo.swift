//
//  ChainHippo.swift
//  Cosmostation
//
//  Created by 차소민 on 4/22/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainHippo: BaseChain {
    override init() {
        super.init()
        
        name = "Hippo Protocol"
        tag = "hippocrat"
        apiName = "hippocrat"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/0'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ahp"
        bechAccountPrefix = "hippo"
        validatorPrefix = "hippovaloper"
        grpcHost = ""
        lcdUrl = "https://api.hippo-protocol.com/"
    }
}
