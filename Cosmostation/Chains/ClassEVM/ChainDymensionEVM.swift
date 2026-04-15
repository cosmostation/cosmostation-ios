//
//  ChainDymensionEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainDymensionEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Dymension"
        tag = "dymension60"
        chainImg = "chainDymension_E"
        apiName = "dymension"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "adym"
        bechAccountPrefix = "dym"
        validatorPrefix = "dymvaloper"
        grpcHost = "grpc.dymension.nodestake.org"
        lcdUrl = "https://api.dymension.nodestake.org/"
        
        supportEvm = true
        coinSymbol = "DYM"
        evmRpcURL = "https://jsonrpc.dymension.nodestake.org"
    }
}
