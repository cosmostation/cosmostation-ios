//
//  ChainXplaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainXplaEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Xpla"
        tag = "xplaKeccak256"
        logo1 = "chainXplaEvm"
        logo2 = "chainXpla2"
        apiName = "xpla"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "axpla"
        bechAccountPrefix = "xpla"
        validatorPrefix = "xplavaloper"
        grpcHost = "grpc-xpla.cosmostation.io"
        
        
        supportEvm = true
        coinSymbol = "XPLA"
        coinGeckoId = "xpla"
        coinLogo = "tokenXpla"
        evmRpcURL = "https://rpc-xpla-evm.cosmostation.io"
        
        initFetcher()
    }
}

