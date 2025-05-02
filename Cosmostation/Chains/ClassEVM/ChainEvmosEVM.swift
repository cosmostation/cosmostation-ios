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
        chainImg = "chainEvmos_E"
        apiName = "evmos"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "aevmos"
        bechAccountPrefix = "evmos"
        validatorPrefix = "evmosvaloper"
        grpcHost = "evmos-grpc.stake-town.com"
        lcdUrl = "https://evmos-api.polkachu.com/"
    
        supportEvm = true
        coinSymbol = "EVMOS"
        evmRpcURL = "https://evmos-evm.publicnode.com"
    }
}
