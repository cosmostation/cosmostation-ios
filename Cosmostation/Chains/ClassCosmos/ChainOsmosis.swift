//
//  ChainOsmosis.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOsmosis: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Osmosis"
        tag = "osmosis118"
        logo1 = "chainOsmosis"
        apiName = "osmosis"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uosmo"
        bechAccountPrefix = "osmo"
        validatorPrefix = "osmovaloper"
        grpcHost = "grpc-osmosis.cosmostation.io"
    }
    
}

let OSMO_NAME_SERVICE = "osmo1xk0s8xgktn9x5vwcgtjdxqzadg88fgn33p8u9cnpdxwemvxscvast52cdd"
