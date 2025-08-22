//
//  ChainCelo.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/13/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainCelo: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Celo"
        tag = "celo60"
        chainImg = "chainCelo"
        apiName = "celo"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "CELO"
        evmRpcURL = "https://rpc.ankr.com/celo"
    }
    
}
