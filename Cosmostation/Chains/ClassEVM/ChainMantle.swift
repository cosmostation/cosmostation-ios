//
//  ChainMantle.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/2/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainMantle: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Mantle"
        tag = "mantle60"
        chainImg = "chainMantle"
        apiName = "mantle"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "MNT"
        evmRpcURL = "https://rpc.mantle.xyz"
    }
    
}
