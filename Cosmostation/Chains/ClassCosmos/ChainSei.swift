//
//  ChainSei.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSei: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Sei"
        tag = "sei118"
        logo1 = "chainSei"
        logo2 = "chainSei2"
        apiName = "sei"
        stakeDenom = "usei"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "sei"
        
        grpcHost = "grpc-sei.cosmostation.io"
    }
}
