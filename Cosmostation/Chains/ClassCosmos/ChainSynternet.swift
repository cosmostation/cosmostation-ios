//
//  ChainSynternet.swift
//  Cosmostation
//
//  Created by 차소민 on 12/13/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainSynternet: BaseChain {
    
    override init() {
        super.init()
        
        name = "Synternet"
        tag = "synternet118"
        apiName = "synternet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "usynt"
        bechAccountPrefix = "synt"
        validatorPrefix = "syntvaloper"
        grpcHost = ""
        lcdUrl = "https://api.synternet.com/"
    }
}
