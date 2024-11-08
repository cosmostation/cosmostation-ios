//
//  ChainAioz.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAioz: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Aioz"
        tag = "aioz60"
        logo1 = "chainAioz"
        apiName = "aioz"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "attoaioz"
        bechAccountPrefix = "aioz"
        validatorPrefix = "aiozvaloper"
        grpcHost = ""
        lcdUrl = "https://lcd-dataseed.aioz.network/"
        
        supportEvm = true
        coinSymbol = "AIOZ"
        coinGeckoId = "aioz-network"
        coinLogo = "tokenAioz"
        evmRpcURL = "https://eth-dataseed.aioz.network"
    }
}

