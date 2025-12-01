//
//  ChainZkSync.swift
//  Cosmostation
//
//  Created by yongjoo jung on 12/1/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZkSync: BaseChain  {
    
    override init() {
        super.init()
        
        name = "ZKsync"
        tag = "zksync60"
        chainImg = "chainZksync"
        apiName = "zksync"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ZK"
        evmRpcURL = "https://mainnet.era.zksync.io"
    }
}
