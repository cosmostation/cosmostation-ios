//
//  ChainJuno.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainJuno: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Juno"
        tag = "juno118"
        logo1 = "chainJuno"
        logo2 = "chainJuno2"
        supportCosmos = true
        apiName = "juno"
        
        stakeDenom = "ujuno"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "juno"
        validatorPrefix = "junovaloper"
        supportCw20 = true
//        supportCw721 = true
        grpcHost = "grpc-juno.cosmostation.io"
        
        initFetcher()
    }
    
}
