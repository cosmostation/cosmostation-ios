//
//  ChainMigaloo.swift
//  Cosmostation
//
//  Created by 차소민 on 10/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainMigaloo: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Migaloo"
        tag = "migaloo118"
        chainImg = "chainMigaloo"
        apiName = "migaloo"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uwhale"
        bechAccountPrefix = "migaloo"
        validatorPrefix = "migaloovaloper"
        grpcHost = "migaloo-grpc.lavenderfive.com"
        lcdUrl = "https://migaloo-rest.publicnode.com/"
    }
}
