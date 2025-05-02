//
//  ChainNyx.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainNyx: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Nym"
        tag = "nyx118"
        chainImg = "chainNyx"
        apiName = "nyx"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "unyx"
        bechAccountPrefix = "n"
        validatorPrefix = "nvaloper"
        grpcHost = "grpc.nymtech.net"
        lcdUrl = "https://nym-api.polkachu.com/"
    }
}
