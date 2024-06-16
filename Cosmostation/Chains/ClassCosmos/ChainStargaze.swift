//
//  ChainStargaze.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStargaze: BaseChain {
    
    override init() {
        super.init()
        
        name = "Stargaze"
        tag = "stargaze118"
        logo1 = "chainStargaze"
        logo2 = "chainStargaze2"
        apiName = "stargaze"
        supportCosmos = true
        
        stakeDenom = "ustars"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "stars"
        validatorPrefix = "starsvaloper"
        supportCw721 = true
        grpcHost = "grpc-stargaze.cosmostation.io"
        
        initFetcher()
    }
}

let STARGAZE_NAME_SERVICE = "stars1fx74nkqkw2748av8j7ew7r3xt9cgjqduwn8m0ur5lhe49uhlsasszc5fhr"
