//
//  ChainLinea.swift
//  Cosmostation
//
//  Created by 권혁준 on 9/26/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainLinea: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Linea"
        tag = "linea60"
        chainImg = "chainLinea"
        apiName = "linea"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        evmRpcURL = "https://rpc.linea.build"
    }
}
