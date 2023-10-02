//
//  ChainAxelar.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainAxelar: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Axelar"
        tag = "axelar118"
        logo1 = "chainAxelar"
        logo2 = "chainAxelar2"
        apiName = "axelar"
        stakeDenom = "uaxl"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "axelar"
        
        grpcHost = "grpc-axelar.cosmostation.io"
    }
    
}
