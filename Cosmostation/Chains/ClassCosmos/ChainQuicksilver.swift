//
//  ChainQuicksilver.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainQuicksilver: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Quicksilver"
        tag = "quicksilver118"
        logo1 = "chainQuicksilver"
        logo2 = "chainQuicksilver2"
        apiName = "quicksilver"
        stakeDenom = "uqck"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "quick"
        
        grpcHost = "grpc-quicksilver.cosmostation.io"
    }
}
