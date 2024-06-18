//
//  File.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainAkash: BaseChain {
    
    override init() {
        super.init()
        
        name = "Akash"
        tag = "akash118"
        logo1 = "chainAkash"
        logo2 = "chainAkash2"
        apiName = "akash"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uakt"
        bechAccountPrefix = "akash"
        validatorPrefix = "akashvaloper"
        grpcHost = "grpc-akash.cosmostation.io"
        
        initFetcher()
    }
    
}

/*
class ChainAkash: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Akash"
        tag = "akash118"
        logo1 = "chainAkash"
        logo2 = "chainAkash2"
        apiName = "akash"
        stakeDenom = "uakt"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "akash"
        validatorPrefix = "akashvaloper"
        
        grpcHost = "grpc-akash.cosmostation.io"
    }
    
}
*/
