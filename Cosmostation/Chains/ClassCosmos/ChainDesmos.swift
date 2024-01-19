//
//  ChainDesmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainDesmos: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Desmos"
        tag = "desmos852"
        logo1 = "chainDesmos"
        logo2 = "chainDesmo2"
        apiName = "desmos"
        stakeDenom = "udsm"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/852'/0'/0/X")
        bechAccountPrefix = "desmos"
        validatorPrefix = "desmosvaloper"
        
        grpcHost = "grpc-desmos.cosmostation.io"
    }
    
}
