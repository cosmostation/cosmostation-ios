//
//  ChainEpixEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 12/17/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainEpixEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Epix"
        tag = "epix60"
        chainImg = "chainEpix_E"
        apiName = "epix"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "aepix"
        bechAccountPrefix = "epix"
        validatorPrefix = "epixvaloper"
        grpcHost = "grpc.epix.zone:15067"
        lcdUrl = "https://api.epix.zone/"
    
        supportEvm = true
        coinSymbol = "EPIX"
        evmRpcURL = "https://evmrpc.epix.zone"
    }
}

