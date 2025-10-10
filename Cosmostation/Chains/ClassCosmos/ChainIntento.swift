//
//  ChainIntento.swift
//  Cosmostation
//
//  Created by 권혁준 on 10/10/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainIntento: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Intento"
        tag = "intento118"
        chainImg = "chainIntento"
        apiName = "intento"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uinto"
        bechAccountPrefix = "into"
        validatorPrefix = "intovaloper"
        grpcHost = ""
        lcdUrl = "https://lcd-mainnet.intento.zone/"
    }
}
