//
//  ChainSentinel.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSentinel: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Sentinel"
        tag = "sentinel118"
        logo1 = "chainSentinel"
        logo2 = "chainSentinel2"
        apiName = "sentinel"
        stakeDenom = "udvpn"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "sent"
        validatorPrefix = "sentvaloper"
        
        grpcHost = "grpc-sentinel.cosmostation.io"
    }
}
