//
//  ChainBlast.swift
//  Cosmostation
//
//  Created by 권혁준 on 9/26/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBlast: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Blast"
        tag = "blast60"
        chainImg = "chainBlast"
        apiName = "blast"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        evmRpcURL = "https://rpc.blast.io"
    }
}
