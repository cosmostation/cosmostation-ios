//
//  ChainStargaze.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStargaze: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Stargaze"
        tag = "stargaze118"
        logo1 = "chainStargaze"
        logo2 = "chainStargaze2"
        apiName = "stargaze"
        stakeDenom = "ustars"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "stars"
        
        grpcHost = "grpc-stargaze.cosmostation.io"
    }
    
}
