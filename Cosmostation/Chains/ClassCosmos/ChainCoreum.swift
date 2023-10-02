//
//  ChainCoreum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCoreum: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Coreum"
        tag = "coreum990"
        logo1 = "chainCoreum"
        logo2 = "chainCoreum2"
        apiName = "coreum"
        stakeDenom = "ucore"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/990'/0'/0/X")
        accountPrefix = "core"
        
        grpcHost = "grpc-coreum.cosmostation.io"
    }
    
}
