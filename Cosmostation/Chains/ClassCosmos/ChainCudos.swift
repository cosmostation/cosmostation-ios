//
//  ChainCudos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCudos: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Cudos"
        tag = "cudos118"
        logo1 = "chainCudos"
        logo2 = "chainCudos2"
        apiName = "cudos"
        stakeDenom = "acudos"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "cudos"
        
        grpcHost = "grpc-cudos.cosmostation.io"
    }
    
}

