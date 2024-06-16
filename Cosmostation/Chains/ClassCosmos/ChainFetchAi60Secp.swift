//
//  ChainFetchAi60Secp.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainFetchAi60Secp: BaseChain {
    
    override init() {
        super.init()
        
        name = "Fetch.Ai"
        tag = "fetchai60_Secp"
        logo1 = "chainFetchAi"
        logo2 = "chainFetchAi2"
        isDefault = false
        supportCosmos = true
        apiName = "fetchai"
        
        stakeDenom = "afet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "fetch"
        validatorPrefix = "fetchvaloper"
        grpcHost = "grpc-fetchai.cosmostation.io"
        
        initFetcher()
    }
    
}

