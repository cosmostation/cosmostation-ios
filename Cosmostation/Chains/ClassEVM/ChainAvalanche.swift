//
//  ChainAvalanche.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/17/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAvalanche: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Avalanche"
        tag = "avalanche60"
        chainImg = "chainAvalanche"
        apiName = "avalanche"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "AVAX"
        evmRpcURL = "https://avalanche.drpc.org"
    }
    
}
