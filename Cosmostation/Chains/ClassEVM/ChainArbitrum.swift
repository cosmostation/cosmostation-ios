//
//  ChainArbitrum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/17/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainArbitrum: EvmClass  {
    
    override init() {
        super.init()
        
        name = "Arbitrum"
        tag = "arbitrum60"
        logo1 = "chainArbitrum"
        logo2 = "chainArbitrum2"
        apiName = "arbitrum"
        
        coinSymbol = "ETH"
        coinGeckoId = "ethereum"
        coinLogo = "tokenEth_arb"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        evmRpcURL = "https://arb1.arbitrum.io/rpc"
        
    }
    
}