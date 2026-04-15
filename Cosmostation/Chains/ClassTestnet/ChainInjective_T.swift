//
//  ChainInjective_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/7/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainInjective_T: ChainInjective {
    
    override init() {
        super.init()
        
        name = "Injective Testnet"
        tag = "injective60_T"
        chainImg = "chainInjective_T"
        isTestnet = true
        apiName = "injective-testnet"
        accountKeyType = AccountKeyType(.INJECTIVE_Secp256k1, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "inj"
        bechAccountPrefix = "inj"
        validatorPrefix = "injvaloper"
        grpcHost = "testnet.sentry.chain.grpc.injective.network:443"
        lcdUrl = "https://testnet.sentry.lcd.injective.network:443"
        
        
        supportEvm = true
        coinSymbol = "INJ"
        evmRpcURL = "https://testnet.sentry.chain.json-rpc.injective.network/"
    }
}
