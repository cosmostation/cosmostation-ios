//
//  ChainInjective.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainInjective: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Injective"
        tag = "injective60"
        chainImg = "chainInjective_E"
        apiName = "injective"
        accountKeyType = AccountKeyType(.INJECTIVE_Secp256k1, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "inj"
        bechAccountPrefix = "inj"
        validatorPrefix = "injvaloper"
        grpcHost = "sentry.chain.grpc.injective.network"
        lcdUrl = "https://injective-rest.publicnode.com/"
        
        supportEvm = true
        coinSymbol = "INJ"
        evmRpcURL = "https://sentry.evm-rpc.injective.network"
    }
}
