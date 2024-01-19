//
//  ChainRizon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainRizon: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Rizon"
        tag = "rizon118"
        logo1 = "chainRizon"
        logo2 = "chainRizon2"
        apiName = "rizon"
        stakeDenom = "uatolo"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "rizon"
        validatorPrefix = "rizonvaloper"
        
        grpcHost = "grpc-rizon.cosmostation.io"
    }
}
