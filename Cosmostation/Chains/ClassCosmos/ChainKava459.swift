//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava459: ChainKavaEVM {
    
    override init() {
        super.init()
        
        name = "Kava"
        tag = "kava459"
        chainImg = "chainKava"
        isDefault = false
        apiName = "kava"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/459'/0'/0/X")

        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ukava"
        bechAccountPrefix = "kava"
        validatorPrefix = "kavavaloper"
        grpcHost = "grpc-kava.cosmostation.io"
        lcdUrl = "https://lcd-kava.cosmostation.io/"
        
        supportEvm = false
        coinSymbol = ""
        evmRpcURL = ""
    }
}
