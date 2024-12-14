//
//  ChainRouterEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 12/13/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainRouterEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Routerchain"
        tag = "router60"
        logo1 = "chainRouter"
        apiName = "routerchain"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "route"
        bechAccountPrefix = "router"
        validatorPrefix = "routervaloper"
        grpcHost = "grpc.router.nodestake.org"
        lcdUrl = "https://sentry.lcd.routerprotocol.com/"
        
        supportEvm = true
        coinSymbol = "ROUTE"
        coinGeckoId = "router-protocol-2"
        coinLogo = "tokenRoute"
        evmRpcURL = "https://sentry.evm.rpc.routerprotocol.com"
    }
}
