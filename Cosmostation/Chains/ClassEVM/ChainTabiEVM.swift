//
//  ChainTabiEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/3/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainTabiEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "TabiChain"
        tag = "tabi60"
        chainImg = "chainTabi_E"
        apiName = "tabichain"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .Unknown
        stakeDenom = "atabi"
        bechAccountPrefix = "tabis"
        validatorPrefix = "tabisvaloper"
        grpcHost = ""
        lcdUrl = ""
    
        supportEvm = true
        coinSymbol = "TABI"
        evmRpcURL = ""
    }
}
