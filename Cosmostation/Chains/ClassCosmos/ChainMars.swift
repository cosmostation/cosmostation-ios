//
//  ChainMars.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainMars: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Mars"
        tag = "mars-protocol118"
        logo1 = "chainMars"
        logo2 = "chainMars2"
        supportCosmos = true
        apiName = "mars-protocol"
        
        stakeDenom = "umars"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "mars"
        validatorPrefix = "marsvaloper"
        grpcHost = "grpc-mars-protocol.cosmostation.io"
        
        initFetcher()
    }
}

