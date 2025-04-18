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
        apiName = "humans"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "aheart"
        bechAccountPrefix = "human"
        validatorPrefix = "humanvaloper"
        grpcHost = "grpc-humans.cosmostation.io"
        lcdUrl = "https://lcd-humans.cosmostation.io/"
        
        supportEvm = true
        coinSymbol = "HEART"
        evmRpcURL = "https://rpc-humans-evm.cosmostation.io"
    }
}
