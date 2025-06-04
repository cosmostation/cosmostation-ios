//
//  ChainQubeticsEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/4/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainQubeticsEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Qubetics"
        tag = "qubetics60"
        chainImg = "chainQubetics_E"
        apiName = "qubetics"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .Unknown
        stakeDenom = "tics"
        bechAccountPrefix = "qubetics"
        validatorPrefix = "qubeticsvaloper"
        grpcHost = ""
        lcdUrl = ""
        
        supportEvm = true
        coinSymbol = "TICS"
        evmRpcURL = ""
    }

}
