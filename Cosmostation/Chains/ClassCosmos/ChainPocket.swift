//
//  ChainPocket.swift
//  Cosmostation
//
//  Created by 권혁준 on 9/16/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainPocket: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Pocket"
        tag = "pocket118"
        chainImg = "chainPocket"
        apiName = "pocket"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "upokt"
        bechAccountPrefix = "pokt"
        validatorPrefix = "poktvaloper"
        grpcHost = ""
        lcdUrl = "https://shannon-grove-api.mainnet.poktroll.com/"
    }
}
