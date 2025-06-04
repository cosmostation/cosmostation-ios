//
//  ChainZigChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/4/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZigChain: BaseChain  {
    
    override init() {
        super.init()
        
        name = "ZigChain"
        tag = "zigchain118"
        chainImg = "chainZig"
        apiName = "zigchain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .Unknown
        stakeDenom = "uzig"
        bechAccountPrefix = "zig"
        validatorPrefix = "zigvaloper"
        grpcHost = ""
        lcdUrl = ""
    }
}
