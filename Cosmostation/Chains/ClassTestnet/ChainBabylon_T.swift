//
//  ChainBabylon_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/8/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBabylon_T: ChainBabylon {
    
    override init() {
        super.init()
        
        name = "Babylon Testnet"
        tag = "babylon118_T"
        chainImg = "chainBabylon_T"
        isTestnet = true
        apiName = "babylon-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubbn"
        bechAccountPrefix = "bbn"
        validatorPrefix = "bbnvaloper"
        grpcHost = ""
        lcdUrl = "https://babylon-testnet-api.nodes.guru/"
    }
}
