//
//  ChainGravityAlpha.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/13/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainGravityAlpha: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Gravity Alpha"
        tag = "gravity-alpha60"
        chainImg = "chainGravityAlpha"
        apiName = "gravity-alpha"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "G"
        evmRpcURL = "https://rpc.gravity.xyz"
    }
    
}

