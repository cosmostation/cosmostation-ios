//
//  ChainQuicksilver.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainQuicksilver: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Quicksilver"
        tag = "quicksilver118"
        logo1 = "chainQuicksilver"
        apiName = "quicksilver"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uqck"
        bechAccountPrefix = "quick"
        validatorPrefix = "quickvaloper"
        grpcHost = "grpc-quicksilver.cosmostation.io"
    }
}
