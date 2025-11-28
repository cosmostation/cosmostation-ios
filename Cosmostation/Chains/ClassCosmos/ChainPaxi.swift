//
//  ChainPaxi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/21/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainPaxi: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Paxi"
        tag = "paxi118"
        chainImg = "chainPaxi"
        apiName = "paxi"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "upaxi"
        bechAccountPrefix = "paxi"
        validatorPrefix = "paxivaloper"
        grpcHost = "mainnet-rpc.paxinet.io"
        lcdUrl = "https://mainnet-lcd.paxinet.io/"
    }
}

