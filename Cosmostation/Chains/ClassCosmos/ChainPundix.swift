//
//  ChainPundix.swift
//  Cosmostation
//
//  Created by 차소민 on 12/27/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainPundix: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Pundi-X"
        tag = "pundix60"
        logo1 = "chainPundix"
        apiName = "pundix"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ibc/55367B7B6572631B78A93C66EF9FDFCE87CDE372CC4ED7848DA78C1EB1DCDD78"
        bechAccountPrefix = "px"
        validatorPrefix = "pxvaloper"
        grpcHost = ""
        lcdUrl = "https://px-rest.pundix.com/"
    }
    
}
