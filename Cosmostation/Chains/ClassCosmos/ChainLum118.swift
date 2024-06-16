//
//  ChainLum118.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainLum118: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Lum"
        tag = "lum118"
        logo1 = "chainLum"
        logo2 = "chainLum2"
        isDefault = false
        supportCosmos = true
        apiName = "lum"
        
        stakeDenom = "ulum"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "lum"
        validatorPrefix = "lumvaloper"
        grpcHost = "grpc-lum.cosmostation.io"
        
        initFetcher()
    }
    
}
