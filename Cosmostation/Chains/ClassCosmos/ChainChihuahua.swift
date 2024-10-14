//
//  ChainChihuahua.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainChihuahua: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Chihuahua"
        tag = "chihuahua118"
        logo1 = "chainChihuahua"
        apiName = "chihuahua"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uhuahua"
        bechAccountPrefix = "chihuahua"
        validatorPrefix = "chihuahuavaloper"
        supportCw20 = true
        grpcHost = "grpc-chihuahua.cosmostation.io"
        lcdUrl = "https://lcd-chihuahua.cosmostation.io/"
    }
    
}
