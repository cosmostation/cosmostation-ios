//
//  ChainMonad_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/16/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainMonad_T: ChainMonad {
    
    override init() {
        super.init()
        
        name = "Monad Testnet"
        tag = "monad60_T"
        logo1 = "chainMonad_T"
        isTestnet = true
        apiName = "monad-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        supportEvm = true
        coinSymbol = "MON"
        evmRpcURL = "https://testnet-rpc.monad.xyz"
    }
}
