//
//  ChainXplaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainXplaEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Xpla"
        tag = "xplaKeccak256"
        logo1 = "chainXpla"
        logo2 = "chainXpla2"
        apiName = "xpla"
        stakeDenom = "axpla"
        
        //for EVM tx and display
        coinSymbol = "XPLA"
        coinGeckoId = "xpla"
        coinLogo = "tokenXpla"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "xpla"
        validatorPrefix = "xplavaloper"
        
        grpcHost = "grpc-xpla.cosmostation.io"
        rpcURL = "https://dimension-evm-rpc.xpla.dev"
        explorerURL = "https://www.mintscan.io/xpla/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
    }
}

