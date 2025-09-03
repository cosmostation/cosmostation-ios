//
//  ChainWorldchain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/2/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainWorldchain: BaseChain  {
    
    override init() {
        super.init()
        
        name = "World Chain"
        tag = "worldchain60"
        chainImg = "chainWorld"
        apiName = "worldcoin"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        evmRpcURL = "https://worldchain-mainnet.g.alchemy.com/public"
    }
    
}
