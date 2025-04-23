//
//  ChainAgoric564.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAgoric564: BaseChain {
    
    override init() {
        super.init()
        
        name = "Agoric"
        tag = "agoric459"
        apiName = "agoric"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/564'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ubld"
        bechAccountPrefix = "agoric"
        validatorPrefix = "agoricvaloper"
        grpcHost = "grpc-agoric.cosmostation.io"
        lcdUrl = "https://lcd-agoric.cosmostation.io/"
    }
}
