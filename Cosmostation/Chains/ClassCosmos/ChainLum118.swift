//
//  ChainLum118.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainLum118: CosmosClass  {
    
    override init() {
        super.init()
        
        isDefault = false
        name = "Lum"
        id = "lum118"
        logo1 = "chainLum"
        logo2 = "chainLum2"
        apiName = "lum"
        stakeDenom = "ulum"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "lum"
        
        grpcHost = "grpc-lum.cosmostation.io"
    }
    
}
