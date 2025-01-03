//
//  ChainBostrom.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/3/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBostrom: BaseChain {
    
    override init() {
        super.init()
        
        name = "Bostrom"
        tag = "bostrom118"
        logo1 = "chainBostrom"
        apiName = "bostrom"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "boot"
        bechAccountPrefix = "bostrom"
        validatorPrefix = "bostromvaloper"
        grpcHost = "grpc-cyber-ia.cosmosia.notional.ventures:443"
        lcdUrl = "https://lcd.bostrom.cybernode.ai/"
    }
}
