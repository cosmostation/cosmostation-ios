//
//  ChainHaqqEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 11/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainHaqqEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Haqq"
        tag = "haqq60"
        apiName = "haqq"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "aISLM"
        bechAccountPrefix = "haqq"
        validatorPrefix = "haqqvaloper"
        grpcHost = "grpc.haqq.sh"
        lcdUrl = "https://rest.cosmos.haqq.network/"
    
        supportEvm = true
        coinSymbol = "ISLM"
        evmRpcURL = "https://rpc.eth.haqq.network"
    }
    
}
