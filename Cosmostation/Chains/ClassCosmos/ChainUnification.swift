//
//  ChainUnification.swift
//  Cosmostation
//
//  Created by 차소민 on 10/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainUnification: BaseChain {
    
    override init() {
        super.init()
        
        name = "Unification"
        tag = "unification5555"
        apiName = "unification"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/5555'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "nund"
        bechAccountPrefix = "und"
        validatorPrefix = "undvaloper"
        grpcHost = "grpc.unification.io"
        lcdUrl = "https://rest.unification.io/"
    }
}
