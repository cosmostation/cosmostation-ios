//
//  ChainSeda.swift
//  Cosmostation
//
//  Created by 차소민 on 11/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainSeda: BaseChain {
    
    override init() {
        super.init()
        
        name = "Seda"
        tag = "seda118"
        logo1 = "chainSeda"
        apiName = "seda"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "aseda"
        bechAccountPrefix = "seda"
        validatorPrefix = "sedavaloper"
        grpcHost = "seda.grpc.kjnodes.com"
        lcdUrl = "https://lcd.mainnet.seda.xyz/"
    }
}
