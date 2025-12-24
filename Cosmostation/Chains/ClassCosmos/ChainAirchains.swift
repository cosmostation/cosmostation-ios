//
//  ChainAirchains.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainAirchains: BaseChain {
    
    override init() {
        super.init()
        
        name = "Airchains"
        tag = "airchains118"
        chainImg = "chainAirchains"
        apiName = "airchains"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uamf"
        bechAccountPrefix = "air"
        validatorPrefix = "airvaloper"
        grpcHost = ""
        lcdUrl = ""
    }
}
