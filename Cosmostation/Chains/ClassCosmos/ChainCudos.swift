//
//  ChainCudos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCudos: BaseChain {
    
    override init() {
        super.init()
        
        name = "Cudos"
        tag = "cudos118"
        logo1 = "chainCudos"
        apiName = "cudos"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "acudos"
        bechAccountPrefix = "cudos"
        validatorPrefix = "cudosvaloper"
        grpcHost = "grpc-cudos.cosmostation.io"
        lcdUrl = "https://lcd-cudos.cosmostation.io/"
    }
}

