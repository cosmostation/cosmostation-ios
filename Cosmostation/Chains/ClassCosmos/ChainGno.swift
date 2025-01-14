//
//  ChainGno.swift
//  Cosmostation
//
//  Created by 차소민 on 1/6/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainGno: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Gno"
        tag = "gno118"
        logo1 = "chainGno"
        apiName = "gno"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ugnot"
        bechAccountPrefix = "g"
        validatorPrefix = "gvaloper"
        grpcHost = ""
        lcdUrl = ""
        rpcUrl = ""
    }
}
