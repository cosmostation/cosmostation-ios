//
//  ChainPassage.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainPassage: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Passage"
        tag = "passage118"
        logo1 = "chainPassage"
        apiName = "passage"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "upasg"
        bechAccountPrefix = "pasg"
        validatorPrefix = "pasgvaloper"
        grpcHost = "grpc-passage.cosmostation.io"
        
        initFetcher()
    }
}
