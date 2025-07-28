//
//  ChainBluzelle.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/28/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBluzelle: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Bluzelle"
        tag = "bluzelle483"
        chainImg = "chainBluzelle"
        apiName = "bluzelle"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/483'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubnt"
        bechAccountPrefix = "bluzelle"
        validatorPrefix = "bluzellevaloper"
        grpcHost = "a.client.sentry.net.bluzelle.com:9090"
        lcdUrl = "https://rest.cosmos.directory/bluzelle/"
    }
    
}
