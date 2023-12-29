//
//  ChainStafi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStafi: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Stafi"
        tag = "stafi118"
        logo1 = "chainStafi"
        logo2 = "chainStafi2"
        apiName = "stafi"
        stakeDenom = "ufis"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "stafi"
        validatorPrefix = "stafivaloper"
        supportStaking = false
        
        grpcHost = "grpc-stafi.cosmostation.io"
    }
}

