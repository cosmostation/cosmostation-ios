//
//  ChainZkCloud.swift
//  Cosmostation
//
//  Created by 차소민 on 3/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZkCloud: BaseChain {
    
    override init() {
        super.init()
        
        name = "ZkCloud"
        tag = "zkCloud118"
        logo1 = ""
        apiName = "zkcloud"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")

        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uproof"
        bechAccountPrefix = "zkcloud"
        validatorPrefix = "zkcloudvaloper"
        grpcHost = ""
        lcdUrl = ""
    }
}
