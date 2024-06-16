//
//  ChainXpla.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainXpla: BaseChain  {
    
    override init() {
        super.init()
        name = "Xpla"
        tag = "xpla60"
        logo1 = "chainXpla"
        logo2 = "chainXpla2"
        isDefault = false
        supportCosmos = true
        apiName = "xpla"
        
        stakeDenom = "axpla"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "xpla"
        validatorPrefix = "xplavaloper"
        grpcHost = "grpc-xpla.cosmostation.io"
        
        initFetcher()
    }
}
