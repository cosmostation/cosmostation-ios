//
//  ChainSentinel.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSentinel: BaseChain {
    
    override init() {
        super.init()
        
        name = "Sentinel"
        tag = "sentinel118"
        chainImg = "chainSentinel"
        apiName = "sentinel"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "udvpn"
        bechAccountPrefix = "sent"
        validatorPrefix = "sentvaloper"
        grpcHost = ""
        lcdUrl = "https://api-sentinel.busurnode.com/"
    }
}
