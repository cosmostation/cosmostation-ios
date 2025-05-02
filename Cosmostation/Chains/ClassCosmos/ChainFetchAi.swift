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
        
        name = "ASI Alliance"
        tag = "fetchai118"
        chainImg = "chainFetchai"
        apiName = "fetchai"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "afet"
        bechAccountPrefix = "fetch"
        validatorPrefix = "fetchvaloper"
        grpcHost = "grpc-fetchai.cosmostation.io"
        lcdUrl = "https://lcd-fetchai.cosmostation.io/"
    }
    
}
