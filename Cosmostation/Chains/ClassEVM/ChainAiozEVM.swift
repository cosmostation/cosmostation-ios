//
//  ChainAiozEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAiozEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Aioz"
        tag = "aioz60"
        chainImg = "chainAioz_E"
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
        evmRpcURL = "https://eth-dataseed.aioz.network"
    }
}

