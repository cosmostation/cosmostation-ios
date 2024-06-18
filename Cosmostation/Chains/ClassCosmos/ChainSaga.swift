//
//  ChainSaga.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/4/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainSaga: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Saga"
        tag = "saga118"
        logo1 = "chainSaga"
        logo2 = "chainSaga2"
        apiName = "saga"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "usaga"
        bechAccountPrefix = "saga"
        validatorPrefix = "sagavaloper"
        grpcHost = "grpc-saga.cosmostation.io"
        
        initFetcher()
    }
    
}

