//
//  ChainShidoEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 11/12/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainShidoEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Shido"
        tag = "shido60"
        chainImg = "chainShido_E"
        apiName = "shido"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "shido"
        bechAccountPrefix = "shido"
        validatorPrefix = "shidovaloper"
        grpcHost = "grpc.shidoscan.com"
        lcdUrl = "https://swagger.shidoscan.com"
        
        supportEvm = true
        coinSymbol = "SHIDO"
        evmRpcURL = "https://rpc-nodes.shidoscan.com"
    }
}
