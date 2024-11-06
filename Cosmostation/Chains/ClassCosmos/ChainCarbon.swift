//
//  ChainCarbon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCarbon: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Carbon"
        tag = "carbon118"
        logo1 = "chainCarbon"
        apiName = "carbon"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "swth"
        bechAccountPrefix = "swth"
        validatorPrefix = "swthvaloper"
        grpcHost = ""
        lcdUrl = "https://api.carbon.network/"
    }
    
}
