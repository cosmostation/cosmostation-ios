//
//  ChainPersistence118.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainPersistence118: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Persistence"
        id = "persistence118"
        logo1 = "chainPersistence"
        logo2 = "chainPersistence2"
        apiName = "persistence"
        stakeDenom = "uxprt"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "persistence"
        
        grpcHost = "grpc-persistence.cosmostation.io"
    }
    
}
