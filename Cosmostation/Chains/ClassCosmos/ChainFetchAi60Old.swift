//
//  ChainFetchAi60Old.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainFetchAi60Old: BaseChain {
    
    override init() {
        super.init()
        
        name = "ASI Alliance"
        tag = "fetchai60_Old"
        chainImg = "chainFetchai"
        isDefault = false
        apiName = "fetchai"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "afet"
        bechAccountPrefix = "fetch"
        validatorPrefix = "fetchvaloper"
        grpcHost = "grpc-fetchhub.fetch.ai"
        lcdUrl = "https://fetch-api.polkachu.com"
    }
    
}
