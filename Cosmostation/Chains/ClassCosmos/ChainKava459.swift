//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava459: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Kava"
        id = "kava_2222-10"
        logo1 = "chainKava"
        logo2 = ""
        apiName = "kava"
        stakeDenom = "ukava"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/459'/0'/0/X")
        accountPrefix = "kava"
        
        grpcHost = "grpc-kava.cosmostation.io"
    }
}
