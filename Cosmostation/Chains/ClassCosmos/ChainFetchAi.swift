//
//  ChainFetchAi.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainFetchAi: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Fetch.Ai"
        tag = "fetchai118"
        logo1 = "chainFetchAi"
        logo2 = "chainFetchAi2"
        supportCosmos = true
        apiName = "fetchai"
        
        stakeDenom = "afet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "fetch"
        validatorPrefix = "fetchvaloper"
        grpcHost = "grpc-fetchai.cosmostation.io"
        
        initFetcher()
    }
    
}
