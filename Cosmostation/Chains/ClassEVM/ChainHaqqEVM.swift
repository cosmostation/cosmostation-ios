//
//  ChainHaqqEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 11/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainHaqqEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Haqq"
        tag = "haqq60"
        chainImg = "chainHaqq_E"
        apiName = "haqq"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "aISLM"
        bechAccountPrefix = "haqq"
        validatorPrefix = "haqqvaloper"
        grpcHost = "grpc-haqq.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-haqq.mainnet.cosmoslabs.kr/"
    
        supportEvm = true
        coinSymbol = "ISLM"
        evmRpcURL = "https://rpc.eth.haqq.network"
    }
    
}
