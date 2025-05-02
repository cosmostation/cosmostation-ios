//
//  ChainMars.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainMars: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Mars"
        tag = "mars-protocol118"
        chainImg = "chainMars"
        apiName = "mars-protocol"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "umars"
        bechAccountPrefix = "mars"
        validatorPrefix = "marsvaloper"
        grpcHost = "mars-grpc.lavenderfive.com:443"
        lcdUrl = "https://mars-api.polkachu.com/"
    }
}

