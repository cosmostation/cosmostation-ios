//
//  ChainKaia.swift
//  Cosmostation
//
//  Created by 차소민 on 10/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainKaia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Kaia"
        tag = "kaia60"
        logo1 = "chainKaia"
        apiName = "kaia"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "KLAY"
        coinGeckoId = "klay-token"
        coinLogo = "tokenKaia"
        supportStaking = false
        evmRpcURL = "https://public-en.node.kaia.io"        
    }
}
