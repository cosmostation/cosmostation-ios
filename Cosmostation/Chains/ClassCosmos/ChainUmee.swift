//
//  ChainUmee.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainUmee: BaseChain {
    
    override init() {
        super.init()
        
        name = "UX(Umee)"
        tag = "umee118"
        logo1 = "chainUmee"
        apiName = "umee"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uumee"
        bechAccountPrefix = "umee"
        validatorPrefix = "umeevaloper"
        grpcHost = "grpc-umee.cosmostation.io"
        
        initFetcher()
    }
    
}
