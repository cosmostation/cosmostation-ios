//
//  ChainKi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKi: BaseChain  {
    
    override init() {
        super.init()
        
        name = "KiChain"
        tag = "ki118"
        chainImg = "chainKi"
        apiName = "ki-chain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uxki"
        bechAccountPrefix = "ki"
        validatorPrefix = "kivaloper"
        grpcHost = ""
        lcdUrl = "https://kichain.api.m.stavr.tech/"
    }
    
}
