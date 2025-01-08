//
//  ChainElys.swift
//  Cosmostation
//
//  Created by 차소민 on 12/13/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainElys: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Elys"
        tag = "elys118"
        logo1 = "chainElys"
        apiName = "elys"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uelys"
        bechAccountPrefix = "elys"
        validatorPrefix = "elysvaloper"
        supportStaking = false
        grpcHost = ""
        lcdUrl = "https://elys-api.polkachu.com/"
    }
}
