//
//  ChainBitway.swift
//  Cosmostation
//
//  Created by 권혁준 on 6/10/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainBitway: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Bitway"
        tag = "bitway118"
        chainImg = "chainBitway"
        apiName = "bitway"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubtw"
        bechAccountPrefix = "bc"
        validatorPrefix = "bcvaloper"
        grpcHost = "grpc.bitway.com:443"
        lcdUrl = "https://rest.bitway.com/"
    }
}
