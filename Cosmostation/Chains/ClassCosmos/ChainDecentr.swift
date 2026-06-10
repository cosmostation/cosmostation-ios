//
//  ChainDecentr.swift
//  Cosmostation
//
//  Created by 권혁준 on 6/9/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainDecentr: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Decentr"
        tag = "decentr118"
        chainImg = "chainDecentr"
        apiName = "decentr"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "udec"
        bechAccountPrefix = "decentr"
        validatorPrefix = "decentrvaloper"
        grpcHost = ""
        lcdUrl = "https://api.decentr.chaintools.tech/"
    }
    
}
