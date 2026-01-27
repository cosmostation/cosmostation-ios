//
//  ChainMirage.swift
//  Cosmostation
//
//  Created by 권혁준 on 1/15/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainMirage: BaseChain {
    
    override init() {
        super.init()
        
        name = "Mirage"
        tag = "mirage118"
        chainImg = "chainMirage"
        apiName = "mirage"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "umirage"
        bechAccountPrefix = "mirage"
        validatorPrefix = "miragevaloper"
        grpcHost = ""
        lcdUrl = "https://mirage.talk/chain/rest/"
    }
}

