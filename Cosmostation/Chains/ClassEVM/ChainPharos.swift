//
//  ChainPharos.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainPharos: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Pharos"
        tag = "pharos60"
        chainImg = "chainPharos"
        apiName = "pharos"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        supportEvm = true
        coinSymbol = "PHRS"
        evmRpcURL = ""
    }
}
