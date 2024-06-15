//
//  ChainCosmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCosmos: BaseChain {
    
    override init() {
        super.init()
        
        name = "Cosmos"
        tag = "cosmos118"
        logo1 = "chainCosmos"
        logo2 = "chainCosmos2"
        supportCosmos = true
        apiName = "cosmos"
        
        stakeDenom = "uatom"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "cosmos"
        validatorPrefix = "cosmosvaloper"
        grpcHost = "grpc-cosmos.cosmostation.io"
        
        initFetcher()
    }
}
/*
class ChainCosmos: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Cosmos"
        tag = "cosmos118"
        logo1 = "chainCosmos"
        logo2 = "chainCosmos2"
        apiName = "cosmos"
        stakeDenom = "uatom"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "cosmos"
        validatorPrefix = "cosmosvaloper"
        
        grpcHost = "grpc-cosmos.cosmostation.io"
    }
}
*/
