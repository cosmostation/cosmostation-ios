//
//  ChainWemix.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/29/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainWemix: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Wemix"
        tag = "wemix60"
        chainImg = "chainWemix"
        apiName = "wemix"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "WEMIX"
        evmRpcURL = "https://api.wemix.com"
    }
    
}

