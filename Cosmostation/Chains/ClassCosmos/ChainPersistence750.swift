//
//  ChainPersistence750.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainPersistence750: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Persistence"
        tag = "persistence750"
        logo1 = "chainPersistence"
        logo2 = "chainPersistence2"
        isDefault = false
        apiName = "persistence"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/750'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uxprt"
        bechAccountPrefix = "persistence"
        validatorPrefix = "persistencevaloper"
        grpcHost = "grpc-persistence.cosmostation.io"
        
        initFetcher()
    }
    
}
