//
//  ChainEvmosEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainEvmosEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Evmos"
        tag = "evmos60"
        logo1 = "chainEvmosEvm"
        logo2 = "chainEvmos2"
        apiName = "evmos"
        stakeDenom = "aevmos"
        
        //for EVM tx and display
        coinSymbol = "EVMOS"
        coinGeckoId = "evmos"
        coinLogo = "tokenEvmos"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "evmos"
        validatorPrefix = "evmosvaloper"
        
        grpcHost = "grpc-evmos.cosmostation.io"
        evmRpcURL = "https://rpc-evmos-evm.cosmostation.io"
        explorerURL = "https://www.mintscan.io/evmos/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
    }
}
