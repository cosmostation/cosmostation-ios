//
//  ChainComdex.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainComdex: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Comdex"
        tag = "comdex118"
        apiName = "comdex"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ucmdx"
        bechAccountPrefix = "comdex"
        validatorPrefix = "comdexvaloper"
        grpcHost = "comdex-grpc.lavenderfive.com"
        lcdUrl = "https://rest.comdex.one/"
    }
    
}
