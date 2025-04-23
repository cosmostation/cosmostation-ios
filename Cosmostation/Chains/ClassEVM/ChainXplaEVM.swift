//
//  ChainXplaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainXplaEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Xpla"
        tag = "xplaKeccak256"
        apiName = "xpla"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "axpla"
        bechAccountPrefix = "xpla"
        validatorPrefix = "xplavaloper"
        grpcHost = "grpc-xpla.cosmostation.io"
        lcdUrl = "https://lcd-xpla.cosmostation.io/"
        
        supportEvm = true
        coinSymbol = "XPLA"
        evmRpcURL = "https://rpc-xpla-evm.cosmostation.io"
    }
}

