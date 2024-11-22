//
//  ChainDoraVota.swift
//  Cosmostation
//
//  Created by 차소민 on 11/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainDoraVota: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Dora Vota"
        tag = "doravota118"
        logo1 = "chainDoravota"
        apiName = "doravota"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "peaka"
        bechAccountPrefix = "dora"
        validatorPrefix = "doravaloper"
        grpcHost = "vota-grpc.dorafactory.org"
        lcdUrl = "https://vota-rest.dorafactory.org"
    }
    
}
