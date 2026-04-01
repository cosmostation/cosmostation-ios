//
//  ChainArtelaEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

//class ChainArtelaEVM_T: ChainArtelaEVM  {
class ChainArtelaEVM_T: BaseChain {
    
    override init() {
        super.init()
        
        name = "Artela Testnet"
        tag = "artela60_T"
        chainImg = "chainArtela_T"
        isTestnet = true
        apiName = "artela-testnet"
        accountKeyType = AccountKeyType(.ARTELA_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uart"
        bechAccountPrefix = "art"
        validatorPrefix = "artvaloper"
        grpcHost = ""
        lcdUrl = ""
        
        
        supportEvm = true
        coinSymbol = "ART"
        evmRpcURL = ""
    }
}
