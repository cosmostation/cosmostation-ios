//
//  ChainMonad.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/16/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainMonad: BaseChain {
    
    override init() {
        super.init()
        
        name = "Monad"
        tag = "monad60"
        apiName = "monad"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        supportEvm = true
        coinSymbol = "MON"
        evmRpcURL = ""
    }
}
