//
//  ChainDydx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainDydx: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Dydx"
        tag = "dydx118"
        logo1 = "chainDydx"
        logo2 = "chainDydx2"
        apiName = "dydx"
        stakeDenom = "adydx"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "dydx"
        
        grpcHost = "grpc-dydx.cosmostation.io"
    }
}
