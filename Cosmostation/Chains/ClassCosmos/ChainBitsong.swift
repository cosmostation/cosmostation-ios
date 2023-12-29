//
//  ChainBitsong.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBitsong: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Bitsong"
        tag = "bitsong639"
        logo1 = "chainBitsong"
        logo2 = "chainBitsong2"
        apiName = "bitsong"
        stakeDenom = "ubtsg"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/639'/0'/0/X")
        bechAccountPrefix = "bitsong"
        validatorPrefix = "bitsongvaloper"
        
        grpcHost = "grpc-bitsong.cosmostation.io"
    }
    
}
