//
//  ChainCantoEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCantoEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Canto"
        tag = "canto60"
        chainImg = "chainCanto"
        apiName = "canto"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "acanto"
        bechAccountPrefix = "canto"
        validatorPrefix = "cantovaloper"
        grpcHost = ""
        lcdUrl = "https://canto-api.polkachu.com/"
        
        supportEvm = true
        coinSymbol = "CANTO"
        evmRpcURL = "https://canto-rpc.ansybl.io"
    }
}
