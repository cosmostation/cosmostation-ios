//
//  ChainBabylon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/8/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainBabylon: BaseChain {
    
    override init() {
        super.init()
        
        name = "Babylon"
        tag = "babylon118"
        logo1 = "chainBabylon"
        apiName = "babylon"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ubbn"
        bechAccountPrefix = "bbn"
        validatorPrefix = "bbnvaloper"
        grpcHost = ""
        lcdUrl = ""
    }
}

