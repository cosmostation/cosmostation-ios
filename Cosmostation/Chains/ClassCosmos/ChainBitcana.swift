//
//  ChainBitcana.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBitcana: BaseChain {
    
    override init() {
        super.init()
        
        name = "Bitcanna"
        tag = "bitcanna118"
        chainImg = "chainBitcanna"
        apiName = "bitcanna"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubcna"
        bechAccountPrefix = "bcna"
        validatorPrefix = "bcnavaloper"
        grpcHost = ""
        lcdUrl = "https://bitcanna.api.m.anode.team/"
    }
    
}
