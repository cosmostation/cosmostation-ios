//
//  ChainKyve.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKyve: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Kyve"
        tag = "kyve118"
        logo1 = "chainKyve"
        logo2 = "chainKyve2"
        apiName = "kyve"
        stakeDenom = "ukyve"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "kyve"
        
        grpcHost = "grpc-kyve.cosmostation.io"
    }
}
