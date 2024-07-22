//
//  ChainAltheaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAltheaEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Althea"
        tag = "althea60"
        logo1 = "chainAltheaEvm"
        apiName = "althea"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "aalthea"
        bechAccountPrefix = "althea"
        validatorPrefix = "altheavaloper"
        grpcHost = "grpc-althea.cosmostation.io"
        lcdUrl = "https://lcd-althea.cosmostation.io/"
        
        supportEvm = true
        coinSymbol = "ALTHEA"
        coinGeckoId = "althea"
        coinLogo = "tokenAltg"
        evmRpcURL = "https://rpc-althea-evm.cosmostation.io"
    }
}
