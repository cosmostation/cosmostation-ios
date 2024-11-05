//
//  ChainTenet.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainTenet: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Tenet"
        tag = "tenet60"
        logo1 = "chainTenet"
        apiName = "tenet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "atenet"
        bechAccountPrefix = "tenet"
        validatorPrefix = "tenetvaloper"
        grpcHost = "tenet-grpc.publicnode.com:443"
        lcdUrl = "https://app.rpc.tenet.org/"
        
        supportEvm = true
        coinSymbol = "TENET"
        coinGeckoId = "tenet-1b000f7b-59cb-4e06-89ce-d62b32d362b9"
        coinLogo = "tokenTenet"
        evmRpcURL = "https://eth-dataseed.aioz.network"
    }
}
