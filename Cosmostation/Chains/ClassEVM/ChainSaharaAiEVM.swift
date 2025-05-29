//
//  ChainSaharaAiEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSaharaAiEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Sahara AI"
        tag = "sahara60"
        chainImg = "chainSaharaaI_E"
        apiName = "saharaai"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .Unknown
        stakeDenom = ""
        bechAccountPrefix = "sah"
        validatorPrefix = "sahoper"
        grpcHost = ""
        lcdUrl = ""
    
        supportEvm = true
        coinSymbol = "SAH"
        evmRpcURL = ""
    }
}

