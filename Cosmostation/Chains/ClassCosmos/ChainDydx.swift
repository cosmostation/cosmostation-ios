//
//  ChainDydx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainDydx: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Dydx"
        tag = "dydx118"
        logo1 = "chainDydx"
        apiName = "dydx"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "adydx"
        bechAccountPrefix = "dydx"
        validatorPrefix = "dydxvaloper"
        grpcHost = "grpc-dydx.cosmostation.io"
    }
}

let DYDX_USDC_DENOM = "ibc/8E27BA2D5493AF5636760E354E46004562C46AB7EC0CC4C1CA14E9E20E2545B5"
