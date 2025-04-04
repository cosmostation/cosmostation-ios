//
//  ChainFxcoreEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 12/30/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainFxcoreEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Function-X"
        tag = "fxcore60"
        logo1 = "chainFxcore"
        apiName = "fxcore"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "FX"
        bechAccountPrefix = "fx"
        validatorPrefix = "fxvaloper"
        grpcHost = ""
        lcdUrl = "https://fx-rest.functionx.io/"
    
        supportEvm = true
        coinSymbol = "FX"
        evmRpcURL = "https://fx-json-web3.functionx.io:8545/"
    }
}
