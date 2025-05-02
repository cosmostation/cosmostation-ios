//
//  ChainCronos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/17/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCronos: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Cronos"
        tag = "cronos60"
        chainImg = "chainCronos"
        apiName = "cronos"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "CRO"
        evmRpcURL = "https://evm.cronos.org"
    }
    
}
