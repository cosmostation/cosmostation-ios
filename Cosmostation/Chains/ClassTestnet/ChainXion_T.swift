//
//  ChainXion_T.swift
//  Cosmostation
//
//  Created by 차소민 on 2/6/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainXion_T: ChainXion {
    
    override init() {
        super.init()
        
        name = "Xion Testnet"
        tag = "xion118_T"
        chainImg = "chainXion_T"
        isTestnet = true
        apiName = "xion-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uxion"
        bechAccountPrefix = "xion"
        validatorPrefix = "xionvaloper"
        grpcHost = ""
        lcdUrl = "https://api.xion-testnet-2.burnt.com/"
    }

}
