//
//  ChainSecret.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSecret118: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Secret"
        tag = "secret118"
        logo1 = "chainSecret"
        logo2 = "chainSecret2"
        isDefault = false
        supportCosmos = true
        apiName = "secret"
        
        stakeDenom = "uscrt"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "secret"
        validatorPrefix = "secretvaloper"
        grpcHost = "grpc-secret.cosmostation.io"
        
        initFetcher()
    }
}
