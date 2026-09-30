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
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "aheart"
        bechAccountPrefix = "human"
        validatorPrefix = "humanvaloper"
        grpcHost = "grpc-humans.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-humans.mainnet.cosmoslabs.kr/"
        
        supportEvm = true
        coinSymbol = "HEART"
        evmRpcURL = "https://humans-mainnet-evm.itrocket.net"
    }
}
