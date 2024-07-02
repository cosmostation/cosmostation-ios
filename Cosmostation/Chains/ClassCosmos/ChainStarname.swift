//
//  ChainStarname.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/02.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStarname: BaseChain {
    
    override init() {
        super.init()
        
        name = "Starname"
        tag = "starname118"
        logo1 = "chainStarname"
        apiName = "starname"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/234'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uiov"
        bechAccountPrefix = "star"
        validatorPrefix = "starvaloper"
        grpcHost = "grpc-starname.cosmostation.io"
    }
    
}
