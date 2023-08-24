//
//  File.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainAkash: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Akash"
        id = "akash118"
        logo1 = "chainAkash"
        logo2 = "chainAkash2"
        apiName = "akash"
        stakeDenom = "uakt"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "akash"
        
        grpcHost = "grpc-akash.cosmostation.io"
    }
    
}

