//
//  ChainSomnia.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/16/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSomnia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Somina"
        tag = "somina60"
        chainImg = "chainSomina_E"
        apiName = "somnia"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "SOMI"
        evmRpcURL = "https://rpc.evm.somnia.mainnet.cosmostation.io/"
    }
}
