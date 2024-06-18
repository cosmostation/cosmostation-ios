//
//  ChainStride.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStride: BaseChain {
    
    override init() {
        super.init()
        
        name = "Stride"
        tag = "stride118"
        logo1 = "chainStride"
        logo2 = "chainStride2"
        apiName = "stride"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "ustrd"
        bechAccountPrefix = "stride"
        validatorPrefix = "stridevaloper"
        grpcHost = "grpc-stride.cosmostation.io"
        
        initFetcher()
    }
}
