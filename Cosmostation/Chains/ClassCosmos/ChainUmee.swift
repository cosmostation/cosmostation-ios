//
//  ChainUmee.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainUmee: CosmosClass {
    
    override init() {
        super.init()
        
        name = "Umee"
        logo1 = "chainUmee"
        logo2 = "chainUmee2"
        apiName = "umee"
        stakeDenom = "uumee"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "umee"
        
        grpcHost = "grpc-umee.cosmostation.io"
    }
    
}
