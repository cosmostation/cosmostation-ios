//
//  ChainRealioEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 12/13/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainRealioEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Realio"
        tag = "realio60"
        apiName = "realio"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ario"
        bechAccountPrefix = "realio"
        validatorPrefix = "realiovaloper"
        grpcHost = ""
        lcdUrl = "https://realio-api.genznodes.dev/"
        
        supportEvm = true
        coinSymbol = "RIO"
        evmRpcURL = "https://realio-rpc-evm.genznodes.dev"
    }

}
