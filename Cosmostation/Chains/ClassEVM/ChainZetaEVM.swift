//
//  ChainZetaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainZetaEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "ZetaChain"
        tag = "zeta60"
        logo1 = "chainZeta"
        apiName = "zeta"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "azeta"
        bechAccountPrefix = "zeta"
        validatorPrefix = "zetavaloper"
        grpcHost = "grpc-zeta.cosmostation.io"
        lcdUrl = "https://lcd-zeta.cosmostation.io/"
    
        supportEvm = true
        coinSymbol = "ZETA"
        coinGeckoId = "zetachain"
        coinLogo = "tokenZeta"
        evmRpcURL = "https://rpc-zeta-evm.cosmostation.io"
    }
}

