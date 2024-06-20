//
//  ChainBaseEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/03/18.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBaseEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Base"
        tag = "base60"
        logo1 = "chainBase"
        apiName = "base"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        coinGeckoId = "weth"
        coinLogo = "tokenEth_base"
        evmRpcURL = "https://mainnet.base.org"
        
        initFetcher()
    }
    
}
