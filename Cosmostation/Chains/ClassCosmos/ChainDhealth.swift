//
//  ChainDhealth.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/3/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainDhealth: BaseChain {
    
    override init() {
        super.init()
        
        name = "dHealth"
        tag = "dhealth118"
        apiName = "dhealth"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/10111'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "udhp"
        bechAccountPrefix = "dh"
        validatorPrefix = "dhvaloper"
        grpcHost = "grpc.dhealth.com:443"
        lcdUrl = "https://lcd.dhealth.com/"
    }
}

