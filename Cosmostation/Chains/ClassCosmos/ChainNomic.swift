//
//  ChainNomic.swift
//  Cosmostation
//
//  Created by 차소민 on 11/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainNomic: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Nomic"
        tag = "nomic118"
        apiName = "nomic"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "unom"
        bechAccountPrefix = "nomic"
        validatorPrefix = "nomicvaloper"
        grpcHost = ""
        lcdUrl = "https://app.nomic.io:8443"
    }
}

