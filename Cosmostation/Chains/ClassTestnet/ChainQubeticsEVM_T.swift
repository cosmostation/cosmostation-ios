//
//  ChainQubeticsEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/4/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainQubeticsEVM_T: ChainQubeticsEVM {
    
    override init() {
        super.init()
        
        name = "Qubetics Testnet"
        tag = "qubetics60_T"
        chainImg = "chainQubetics_T"
        isTestnet = true
        apiName = "qubetics-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "tics"
        bechAccountPrefix = "qubetics"
        validatorPrefix = "qubeticsvaloper"
        grpcHost = ""
        lcdUrl = "https://swagger-testnet.qubetics.work/"
        
        supportEvm = true
        coinSymbol = "TICS"
        evmRpcURL = "https://rpc-testnet.qubetics.work"
    }

}
