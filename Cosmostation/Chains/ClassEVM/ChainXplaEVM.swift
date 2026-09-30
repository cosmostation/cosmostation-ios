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
        chainImg = "chainXpla_E"
        apiName = "xpla"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "axpla"
        bechAccountPrefix = "xpla"
        validatorPrefix = "xplavaloper"
        grpcHost = "grpc-xpla.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-xpla.mainnet.cosmoslabs.kr/"
        
        supportEvm = true
        coinSymbol = "XPLA"
        evmRpcURL = "https://dimension-evm-rpc.xpla.dev"
    }
}

