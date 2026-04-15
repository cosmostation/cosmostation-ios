//
//  ChainMantraEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/18/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainMantraEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Mantra"
        tag = "mantraevm60"
        chainImg = "chainMantra_E"
        apiName = "mantra"
        accountKeyType = AccountKeyType(.COSMOS_EVM_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uom"
        bechAccountPrefix = "mantra"
        validatorPrefix = "mantravaloper"
        grpcHost = "grpc.mantrachain.io"
        lcdUrl = "https://api.mantrachain.io/"
        
        supportEvm = true
        coinSymbol = "OM"
        evmRpcURL = "https://evm.mantrachain.io"
    }
}

