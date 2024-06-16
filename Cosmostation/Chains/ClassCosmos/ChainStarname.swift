//
//  ChainStarname.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/02.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStarname: BaseChain {
    
    override init() {
        super.init()
        
        name = "Starname"
        tag = "starname118"
        logo1 = "chainStarname"
        logo2 = "chainStarname2"
        supportCosmos = true
        apiName = "starname"
        
        stakeDenom = "uiov"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/234'/0'/0/X")
        bechAccountPrefix = "star"
        validatorPrefix = "starvaloper"
        grpcHost = "grpc-starname.cosmostation.io"
        
        initFetcher()
    }
    
}
