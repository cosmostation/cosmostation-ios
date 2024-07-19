//
//  ChainLCDTest.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/16/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainLCDTest: ChainGravityBridge  {
    
    override init() {
        super.init()
        
        name = "G-Bridge LCD"
        tag = "bg TEST"
        logo1 = "chainGravityBridge"
        apiName = "gravity-bridge"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = false
        supportCosmosLcd = true
        stakeDenom = "ugraviton"
        bechAccountPrefix = "gravity"
        validatorPrefix = "gravityvaloper"
        lcdUrl = "https://gravitychain.io:1317/"
    }
}
