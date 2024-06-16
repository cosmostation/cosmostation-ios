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
        logo2 = "chainOptimism2"
        supportEvm = true
        apiName = "optimism"
        
        coinSymbol = "ETH"
        coinGeckoId = "weth"
        coinLogo = "tokenEth_Op"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        evmRpcURL = "https://mainnet.optimism.io"
        
        initFetcher()
    }
    
}
