//
//  ChainCantoEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCantoEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Canto"
        tag = "canto60"
        logo1 = "chainCantoEvm"
        logo2 = "chainCanto2"
        apiName = "canto"
        stakeDenom = "acanto"
        
        //for EVM tx and display
        coinSymbol = "CANTO"
        coinGeckoId = "canto"
        coinLogo = "tokenCanto"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "canto"
        validatorPrefix = "cantovaloper"
        
        grpcHost = "grpc-canto.cosmostation.io"
        evmRpcURL = "https://rpc-canto-evm.cosmostation.io"
        explorerURL = "https://www.mintscan.io/canto/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
    }
}
