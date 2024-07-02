//
//  ChainBinanceSmart.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBinanceSmart: BaseChain  {
    
    override init() {
        super.init()
        
        name = "BSC"
        tag = "binance60"
        logo1 = "chainBinanceSmart"
        apiName = "bnb-smart-chain"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "BNB "
        coinGeckoId = "binancecoin"
        coinLogo = "tokenBnb"
        evmRpcURL = "https://bsc-dataseed.binance.org"
    }
    
}
