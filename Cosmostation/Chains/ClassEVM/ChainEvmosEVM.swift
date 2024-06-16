//
//  ChainEvmosEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainEvmosEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Evmos"
        tag = "evmos60"
        logo1 = "chainEvmosEvm"
        logo2 = "chainEvmos2"
        supportCosmos = true
        supportEvm = true
        apiName = "evmos"
        
        stakeDenom = "aevmos"
        coinSymbol = "EVMOS"
        coinGeckoId = "evmos"
        coinLogo = "tokenEvmos"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "evmos"
        validatorPrefix = "evmosvaloper"
        grpcHost = "grpc-evmos.cosmostation.io"
        evmRpcURL = "https://rpc-evmos-evm.cosmostation.io"
        
        initFetcher()
    }
}
