//
//  ChainKi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKi: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "KiChain"
        tag = "ki118"
        logo1 = "chainKi"
        logo2 = "chainK2"
        apiName = "ki-chain"
        stakeDenom = "uxki"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "ki"
        supportCw20 = true
        
        grpcHost = "grpc-ki-chain.cosmostation.io"
    }
    
}
