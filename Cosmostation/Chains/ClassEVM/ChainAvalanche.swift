//
//  ChainAvalanche.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/17/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAvalanche: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Avalanche"
        tag = "avalanche60"
        logo1 = "chainAvalanche"
        logo2 = "chainAvalanche2"
        supportEvm = true
        apiName = "avalanche"
        
        coinSymbol = "AVAX"
        coinGeckoId = "avalanche-2"
        coinLogo = "tokenAvax"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        evmRpcURL = "https://avalanche.public-rpc.com"
        
        initFetcher()
    }
    
}
