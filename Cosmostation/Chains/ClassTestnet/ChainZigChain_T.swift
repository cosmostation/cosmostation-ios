//
//  ChainZigChain_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/4/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZigChain_T: ChainZigChain  {
    
    override init() {
        super.init()
        
        name = "ZigChain Testnet"
        tag = "zigchain118_T"
        chainImg = "chainZig_T"
        isTestnet = true
        apiName = "zigchain-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uzig"
        bechAccountPrefix = "zig"
        validatorPrefix = "zigvaloper"
        grpcHost = ""
        lcdUrl = "https://testnet-api.zigchain.com/"
    }
}
