//
//  ChainStarname.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/02.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainStarname: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Starname"
        tag = "starname118"
        logo1 = "chainStarname"
        logo2 = "chainStarname2"
        apiName = "starname"
        stakeDenom = "uiov"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/234'/0'/0/X")
        accountPrefix = "star"
        
        grpcHost = "grpc-starname.cosmostation.io"
    }
    
}
