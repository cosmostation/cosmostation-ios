//
//  ChainQuasar.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainQuasar: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Quasar"
        tag = "quasar118"
        logo1 = "chainQuasar"
        apiName = "quasar"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uqsr"
        bechAccountPrefix = "quasar"
        validatorPrefix = "quasarvaloper"
        grpcHost = "grpc-quasar.cosmostation.io"
    }
}
