//
//  ChainMilkyway.swift
//  Cosmostation
//
//  Created by 차소민 on 12/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainMilkyway: BaseChain {
    
    override init() {
        super.init()
        
        name = "Milkyway"
        tag = "milkyway118"
        logo1 = "chainMilkyway"
        apiName = "milkyway"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "umilk"
        bechAccountPrefix = "milk"
        validatorPrefix = "milkvaloper"
        grpcHost = "grpc-milkyway.cosmostation.io"
        lcdUrl = "https://lcd-milkyway.cosmostation.io/"
    }

}
