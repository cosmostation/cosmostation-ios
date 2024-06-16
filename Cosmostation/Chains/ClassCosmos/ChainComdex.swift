//
//  ChainComdex.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainComdex: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Comdex"
        tag = "comdex118"
        logo1 = "chainComdex"
        logo2 = "chainComdex2"
        supportCosmos = true
        apiName = "comdex"
        
        stakeDenom = "ucmdx"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "comdex"
        validatorPrefix = "comdexvaloper"
        grpcHost = "grpc-comdex.cosmostation.io"
        
        initFetcher()
    }
    
}
