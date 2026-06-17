//
//  ChainEmpower.swift
//  Cosmostation
//
//  Created by 권혁준 on 6/16/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainEmpower: BaseChain  {
    
    override init() {
        super.init()
        
        name = "EmpowerChain"
        tag = "empowerchain118"
        chainImg = "chainEmpower"
        apiName = "empower"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "umpwr"
        bechAccountPrefix = "empower"
        validatorPrefix = "empowervaloper"
        grpcHost = ""
        lcdUrl = "https://mainnet-empower-api.konsortech.xyz/"
    }
}
