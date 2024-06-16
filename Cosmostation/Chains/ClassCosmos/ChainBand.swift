//
//  ChainBand.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBand: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Band"
        tag = "band494"
        logo1 = "chainBand"
        logo2 = "chainBand2"
        supportCosmos = true
        apiName = "band"
        
        stakeDenom = "uband"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/494'/0'/0/X")
        bechAccountPrefix = "band"
        validatorPrefix = "bandvaloper"
        grpcHost = "grpc-band.cosmostation.io"
        
        initFetcher()
    }
    
}
