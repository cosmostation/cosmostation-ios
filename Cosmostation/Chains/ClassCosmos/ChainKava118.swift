//
//  ChainKava_Legacy.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava118: ChainKavaEVM  {
    
    override init() {
        super.init()
        
        name = "Kava"
        tag = "kava118"
        logo1 = "chainKava"
        isDefault = false
        apiName = "kava"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "ukava"
        bechAccountPrefix = "kava"
        validatorPrefix = "kavavaloper"
        grpcHost = "grpc-kava.cosmostation.io"
        
        
        supportEvm = false
        coinSymbol = ""
        coinGeckoId = ""
        coinLogo = ""
        evmRpcURL = ""
    }
}
