//
//  ChainUnunifi.swift
//  Cosmostation
//
//  Created by 권혁준 on 6/10/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainUnunifi: BaseChain {
    
    override init() {
        super.init()
        
        name = "Ununifi"
        tag = "ununifi118"
        chainImg = "chainUnunifi"
        apiName = "ununifi"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uguu"
        bechAccountPrefix = "ununifi"
        validatorPrefix = "ununifivaloper"
        grpcHost = ""
        lcdUrl = "https://a.lcd.ununifi.cauchye.net:1318/"
    }
}
