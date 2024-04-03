//
//  ChainBaseEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/03/18.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBaseEVM: EvmClass  {
    
    override init() {
        super.init()
        
        name = "Base"
        tag = "base60"
        logo1 = "chainBase"
        logo2 = "chainBase2"
        apiName = "base"
        
        coinSymbol = "ETH"
        coinGeckoId = "weth"
        coinLogo = "tokenEth_base"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        evmRpcURL = "https://mainnet.base.org"
        
    }
    
}
