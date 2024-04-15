//
//  ChainBinanceSmart.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainBinanceSmart: EvmClass  {
    
    override init() {
        super.init()
        
        name = "Binance Smart"
        tag = "binance60"
        logo1 = "chainBinanceSmart"
        logo2 = "chainBinanceSmart2"
        apiName = "bnb-smart-chain"
        
        coinSymbol = "BNB "
        coinGeckoId = "binancecoin"
        coinLogo = "tokenBnb"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        evmRpcURL = "https://bsc-dataseed.binance.org"
        
    }
    
}
