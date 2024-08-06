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
        
        name = "ASI Alliance"
        tag = "fetchai60_Secp"
        logo1 = "chainASIAlliance"
        isDefault = false
        apiName = "fetchai"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "afet"
        bechAccountPrefix = "fetch"
        validatorPrefix = "fetchvaloper"
        grpcHost = "grpc-fetchai.cosmostation.io"
        lcdUrl = "https://lcd-fetchai.cosmostation.io/"
    }
    
}

