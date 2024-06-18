//
//  ChainFinschia.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/08.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainFinschia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Finschia"
        tag = "finschia438"
        logo1 = "chainFinschia"
        logo2 = "chainFinschia2"
        apiName = "finschia"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/438'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "cony"
        bechAccountPrefix = "link"
        validatorPrefix = "linkvaloper"
        grpcHost = "grpc-finschia.cosmostation.io"
        
        initFetcher()
    }
    
}
