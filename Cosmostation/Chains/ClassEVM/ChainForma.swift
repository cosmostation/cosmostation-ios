//
//  ChainForma.swift
//  Cosmostation
//
//  Created by 차소민 on 12/27/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainForma: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Forma"
        tag = "forma60"
        chainImg = "chainForma"
        apiName = "forma"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "TIA"
        evmRpcURL = "https://rpc.forma.art"
    }
}
