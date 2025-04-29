//
//  ChainAaron.swift
//  Cosmostation
//
//  Created by 차소민 on 12/4/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAaron: BaseChain {
    
    override init() {
        super.init()
        
        name = "Aaron"
        tag = "aaron118"
        apiName = "aaron"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uaaron"
        bechAccountPrefix = "aaron"
        validatorPrefix = "aaronvaloper"
        grpcHost = ""
        lcdUrl = "https://mainnet-api.aaronetwork.xyz/"
    }
}
