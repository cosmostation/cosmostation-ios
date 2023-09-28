//
//  ChainCrescent.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/28.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCrescent: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Crescent"
        id = "crescent118"
        logo1 = "chainCrescent"
        logo2 = "chainCrescent2"
        apiName = "crescent"
        stakeDenom = "ucre"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "cre"
        
        grpcHost = "grpc-crescent.cosmostation.io"
    }
    
}
