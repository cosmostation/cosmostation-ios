//
//  ChainShentu.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainShentu: BaseChain {
    
    override init() {
        super.init()
        
        name = "Shentu"
        tag = "shentu118"
        logo1 = "chainShentu"
        logo2 = "chainShentu2"
        apiName = "shentu"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uctk"
        bechAccountPrefix = "shentu"
        validatorPrefix = "shentuvaloper"
        grpcHost = "grpc-shentu.cosmostation.io"
        
        initFetcher()
    }
    
}
