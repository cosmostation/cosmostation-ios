//
//  ChainScroll.swift
//  Cosmostation
//
//  Created by yongjoo jung on 12/1/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainScroll: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Scroll"
        tag = "scroll60"
        chainImg = "chainScroll"
        apiName = "scroll"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "SCR"
        evmRpcURL = "https://rpc.scroll.io"
    }
}
