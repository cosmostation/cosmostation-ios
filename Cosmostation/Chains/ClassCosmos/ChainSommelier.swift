//
//  ChainSommelier.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSommelier: BaseChain {
    
    override init() {
        super.init()
        
        name = "Sommelier"
        tag = "sommelier118"
        logo1 = "chainSommelier"
        apiName = "sommelier"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        supportCosmosGrpc = true
        stakeDenom = "usomm"
        bechAccountPrefix = "somm"
        validatorPrefix = "sommvaloper"
        grpcHost = "grpc-sommelier.cosmostation.io"
        
        initFetcher()
    }
    
}
