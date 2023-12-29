//
//  ChainQuasar.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainQuasar: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Quasar"
        tag = "quasar118"
        logo1 = "chainQuasar"
        logo2 = "chainQuasar2"
        apiName = "quasar"
        stakeDenom = "uqsr"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "quasar"
        validatorPrefix = "quasarvaloper"
        
        grpcHost = "grpc-quasar.cosmostation.io"
    }
}
