//
//  ChainChihuahua.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainChihuahua: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Chihuahua"
        tag = "chihuahua118"
        logo1 = "chainChihuahua"
        logo2 = "chainChihuahua2"
        apiName = "chihuahua"
        stakeDenom = "uhuahua"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "chihuahua"
        validatorPrefix = "chihuahuavaloper"
        
        grpcHost = "grpc-chihuahua.cosmostation.io"
    }
    
}
