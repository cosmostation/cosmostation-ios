//
//  ChainHumansEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainHumansEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Humans"
        tag = "humans60"
        chainImg = "chainHumans_E"
        apiName = "humans"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "aheart"
        bechAccountPrefix = "human"
        validatorPrefix = "humanvaloper"
        grpcHost = "grpc.humans.nodestake.top"
        lcdUrl = "https://humans-mainnet-api.itrocket.net/"
        
        supportEvm = true
        coinSymbol = "HEART"
        evmRpcURL = "https://jsonrpc.humans.nodestake.top"
    }
}
