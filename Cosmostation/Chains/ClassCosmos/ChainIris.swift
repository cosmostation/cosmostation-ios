//
//  ChainIris.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/15.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainIris: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Iris"
        tag = "iris118"
        logo1 = "chainIris"
        logo2 = "chainIris2"
        apiName = "iris"
        stakeDenom = "uiris"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "iaa"
        
        grpcHost = "grpc-iris.cosmostation.io"
    }
}

