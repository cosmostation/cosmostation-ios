//
//  ChainNibiru.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/12/08.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainNibiru: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Nibiru"
        tag = "nibiru118"
        logo1 = "chainNibiru"
        apiName = "nibiru"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "unibi"
        bechAccountPrefix = "nibi"
        validatorPrefix = "nibivaloper"
        grpcHost = "grpc-nibiru.cosmostation.io"
        lcdUrl = "https://lcd-nibiru.cosmostation.io/"
    }
}

