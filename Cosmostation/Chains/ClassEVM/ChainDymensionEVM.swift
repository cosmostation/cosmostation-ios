//
//  ChainDymensionEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainDymensionEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Dymension"
        tag = "dymension60"
        logo1 = "chainDymensionEvm"
        logo2 = "chainDymension2"
        supportCosmos = true
        supportEvm = true
        apiName = "dymension"
        
        stakeDenom = "adym"
        coinSymbol = "DYM"
        coinGeckoId = "dymension"
        coinLogo = "tokenDym"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "dym"
        validatorPrefix = "dymvaloper"
        grpcHost = "grpc-dymension.cosmostation.io"
        evmRpcURL = "https://rpc-dymension-evm.cosmostation.io"
        
        initFetcher()
    }
}
