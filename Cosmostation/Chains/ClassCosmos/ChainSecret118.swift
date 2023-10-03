//
//  ChainSecret.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSecret118: CosmosClass  {
    
    override init() {
        super.init()
        
        isDefault = false
        name = "Secret"
        tag = "secret118"
        logo1 = "chainSecret"
        logo2 = "chainSecret2"
        apiName = "secret"
        stakeDenom = "uscrt"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "secret"
        
        grpcHost = "grpc-secret.cosmostation.io"
    }
}
