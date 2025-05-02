//
//  ChainBase.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/03/18.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBase: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Base"
        tag = "base60"
        chainImg = "chainBase"
        apiName = "base"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        evmRpcURL = "https://mainnet.base.org"
    }
    
}
