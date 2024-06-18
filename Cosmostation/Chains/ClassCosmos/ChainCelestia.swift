//
//  ChainCelestia.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCelestia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Celestia"
        tag = "celestia118"
        logo1 = "chainCelestia"
        logo2 = "chainCelestia2"
        apiName = "celestia"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "utia"
        bechAccountPrefix = "celestia"
        validatorPrefix = "celestiavaloper"
        grpcHost = "grpc-celestia.cosmostation.io"
        
        initFetcher()
    }
}
