//
//  ChainShardeum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/19/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainShardeum: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Shardeum"
        tag = "shardeum60"
        chainImg = "chainShardeum"
        apiName = "shardeum"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "SHM"
        evmRpcURL = "https://api.shardeum.org"
    }
}
