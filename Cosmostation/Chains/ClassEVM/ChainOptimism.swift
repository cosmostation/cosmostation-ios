//
//  ChainOptimism.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/27.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainOptimism: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Optimism"
        tag = "optimism60"
        logo1 = "chainOptimism"
        apiName = "optimism"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        coinGeckoId = "weth"
        coinLogo = "tokenEth_Op"
        evmRpcURL = "https://mainnet.optimism.io"
        
        initFetcher()
    }
    
}
