//
//  ChainNyx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainNyx: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Nyx"
        tag = "nyx118"
        logo1 = "chainNyx"
        logo2 = "chainNyx2"
        apiName = "nyx"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "unyx"
        bechAccountPrefix = "n"
        validatorPrefix = "nvaloper"
        grpcHost = "grpc-nyx.cosmostation.io"
        
        initFetcher()
    }
}
