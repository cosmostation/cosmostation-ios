//
//  ChainRegen.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainRegen: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Regen"
        tag = "regen118"
        logo1 = "chainRegen"
        apiName = "regen"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uregen"
        bechAccountPrefix = "regen"
        validatorPrefix = "regenvaloper"
        grpcHost = "grpc-regen.cosmostation.io"
    }
}
