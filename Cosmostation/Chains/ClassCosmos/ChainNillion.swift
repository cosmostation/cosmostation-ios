//
//  ChainNillion.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainNillion: BaseChain {
    
    override init() {
        super.init()
        
        name = "Nillion"
        tag = "nillion118"
        logo1 = "chainNillion"
        apiName = "nillion"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "unil"
        bechAccountPrefix = "nillion"
        validatorPrefix = "nillionvaloper"
        grpcHost = "grpc-nillion.cosmostation.io"
        lcdUrl = "https://lcd-nillion.cosmostation.io/"
    }
}
