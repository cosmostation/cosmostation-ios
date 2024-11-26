//
//  ChainSge.swift
//  Cosmostation
//
//  Created by 차소민 on 11/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainSge: BaseChain {
    
    override init() {
        super.init()
        
        name = "Sge"
        tag = "sge118"
        logo1 = "chainSge"
        apiName = "sge"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "usge"
        bechAccountPrefix = "sge"
        validatorPrefix = "sgevaloper"
        grpcHost = "sge-grpc.stakerhouse.com"
        lcdUrl = "https://sge-api.polkachu.com/"
    }
}
