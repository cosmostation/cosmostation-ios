//
//  ChainOsmosis.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOsmosis: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Osmosis"
        tag = "osmosis118"
        logo1 = "chainOsmosis"
        logo2 = "chainOsmosis2"
        apiName = "osmosis"
        stakeDenom = "uosmo"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "osmo"
        
        grpcHost = "grpc-osmosis.cosmostation.io"
    }
    
}
