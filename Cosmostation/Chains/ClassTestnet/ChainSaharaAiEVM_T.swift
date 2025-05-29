//
//  ChainSaharaAiEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSaharaAiEVM_T: ChainSaharaAiEVM  {
    
    override init() {
        super.init()
        
        name = "Sahara AI Testnet"
        tag = "sahara_T"
        chainImg = "chainSaharaai_T"
        isTestnet = true
        apiName = "saharaai-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "usah"
        bechAccountPrefix = "sah"
        validatorPrefix = "sahoper"
        grpcHost = ""
        lcdUrl = "https://sahara-api.testnet.moonlet.cloud/public/"
    
        supportEvm = true
        coinSymbol = "SAH"
        evmRpcURL = "https://testnet.saharalabs.ai"
    }
}
