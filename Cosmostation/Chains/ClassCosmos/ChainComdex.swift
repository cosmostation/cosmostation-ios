//
//  ChainComdex.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainComdex: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Comdex"
        id = "comdex118"
        logo1 = "chainComdex"
        logo2 = "chainComdex2"
        apiName = "comdex"
        stakeDenom = "ucmdx"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "comdex"
        
        grpcHost = "grpc-comdex.cosmostation.io"
    }
    
}
