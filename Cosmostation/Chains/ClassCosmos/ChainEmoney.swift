//
//  ChainEmoney.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainEmoney: BaseChain  {
    
    override init() {
        super.init()
        
        name = "E-Money"
        tag = "emoney118"
        chainImg = "chainEmoney"
        apiName = "emoney"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ungm"
        bechAccountPrefix = "emoney"
        validatorPrefix = "emoneyvaloper"
        grpcHost = "grpc-emoney.cosmostation.io"
        lcdUrl = "https://lcd-emoney.cosmostation.io/"
    }
    
}

