//
//  ChainStratosEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 3/12/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainStratosEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Stratos"
        tag = "stratos60"
        logo1 = "chainStratosEvm"
        apiName = "stratos"
        accountKeyType = AccountKeyType(.STRATOS_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "wei"
        bechAccountPrefix = "st"
        validatorPrefix = "stvaloper"
        grpcHost = "grpc.thestratos.org"
        lcdUrl = "https://rest.thestratos.org/"
        
        supportEvm = true
        coinSymbol = "STOS"
        coinGeckoId = "stratos"
        coinLogo = "tokenStos"
        evmRpcURL = "https://web3-rpc.thestratos.org"
    }
}
