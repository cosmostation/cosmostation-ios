//
//  ChainPlanq.swift
//  Cosmostation
//
//  Created by 차소민 on 10/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainPlanq: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Planq"
        tag = "planq60"
        logo1 = "chainPlanq"
        apiName = "planq"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "aplanq"
        bechAccountPrefix = "plq"
        validatorPrefix = "plqvaloper"
        grpcHost = "grpc.planq.network"
        lcdUrl = "https://rest.planq.network/"
        
        supportEvm = true
        coinSymbol = "PLANQ"
        coinGeckoId = ""
        coinLogo = "tokenPlq"
        evmRpcURL = "https://evm-rpc.planq.network"
    }
}
