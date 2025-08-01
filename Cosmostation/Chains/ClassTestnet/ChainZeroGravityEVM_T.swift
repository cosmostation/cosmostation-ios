//
//  ChainZeroGravityEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/29/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZeroGravityEVM_T: ChainZeroGravityEVM  {
    
    override init() {
        super.init()
        
        name = "ØG Testnet"
        tag = "zero-gravity_T"
        chainImg = "chainZeroGravity_T"
        isTestnet = true
        apiName = "zero-gravity-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ØG"
        evmRpcURL = "https://evmrpc-testnet.0g.ai"
    }
}
