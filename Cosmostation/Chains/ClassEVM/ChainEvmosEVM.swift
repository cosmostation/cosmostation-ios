//
//  ChainEvmosEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainEvmosEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Evmos"
        tag = "evmos60"
        logo1 = "chainEvmos"
        apiName = "evmos"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "aevmos"
        bechAccountPrefix = "evmos"
        validatorPrefix = "evmosvaloper"
        grpcHost = "grpc-evmos.cosmostation.io"
        lcdUrl = "https://lcd-evmos.cosmostation.io/"
    
        supportEvm = true
        coinSymbol = "EVMOS"
        coinGeckoId = "evmos"
        coinLogo = "tokenEvmos"
        evmRpcURL = "https://rpc-evmos-evm.cosmostation.io"
    }
}
