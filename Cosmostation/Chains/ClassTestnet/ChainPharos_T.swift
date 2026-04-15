//
//  ChainPharos_T.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainPharos_T: ChainPharos {
    
    override init() {
        super.init()
        
        name = "Pharos Testnet"
        tag = "pharos60_T"
        chainImg = "chainPharos_T"
        isTestnet = true
        apiName = "pharos-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        supportEvm = true
        coinSymbol = "PHRS"
        evmRpcURL = "https://atlantic.dplabs-internal.com"
    }
}
