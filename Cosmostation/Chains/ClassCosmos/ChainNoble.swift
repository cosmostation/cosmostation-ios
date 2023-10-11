//
//  ChainNoble.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainNoble: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Noble"
        tag = "noble118"
        logo1 = "chainNoble"
        logo2 = "chainNoble2"
        apiName = "noble"
        stakeDenom = "ustake"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "noble"
        supportStaking = false
        
        grpcHost = "grpc-noble.cosmostation.io"
    }
}
