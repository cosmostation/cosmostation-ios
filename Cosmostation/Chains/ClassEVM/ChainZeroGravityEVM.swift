//
//  ChainZeroGravityEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/29/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZeroGravityEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "0G"
        tag = "zero-gravity"
        chainImg = "chainZeroGravity"
        apiName = "zero-gravity"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "0G"
        evmRpcURL = ""
    }
}

