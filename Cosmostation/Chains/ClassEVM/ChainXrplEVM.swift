//
//  ChainXrplEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 3/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainXrplEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "XRPL EVM"
        tag = "xrplevm60"
        logo1 = "chainXrplevm"
        apiName = "xrplevm"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        supportEvm = true
        coinSymbol = "XRP"
        coinGeckoId = ""
        coinLogo = "tokenXrp"
        evmRpcURL = ""
    }
}
