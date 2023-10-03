//
//  ChainRegen.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainRegen: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Regen"
        tag = "regen118"
        logo1 = "chainRegen"
        logo2 = "chainRegen2"
        apiName = "regen"
        stakeDenom = "uregen"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "regen"
        
        grpcHost = "grpc-regen.cosmostation.io"
    }
}
