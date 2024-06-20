//
//  ChainEmoney.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainEmoney: BaseChain  {
    
    override init() {
        super.init()
        
        name = "E-Money"
        tag = "emoney118"
        logo1 = "chainEmoney"
        apiName = "emoney"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "ungm"
        bechAccountPrefix = "emoney"
        validatorPrefix = "emoneyvaloper"
        grpcHost = "grpc-emoney.cosmostation.io"
        
        initFetcher()
    }
    
}

