//
//  ChainImuaEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 4/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainImuaEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Imua"
        tag = "imua60"
        chainImg = "chainImua_E"
        apiName = "imua"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "hua"
        bechAccountPrefix = "im"
        validatorPrefix = "imvaloper"
        grpcHost = ""
        lcdUrl = ""
        
        supportEvm = true
        coinSymbol = "IMUA"
        evmRpcURL = ""
    }
}
