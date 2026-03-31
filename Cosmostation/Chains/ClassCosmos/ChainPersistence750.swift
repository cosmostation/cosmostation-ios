//
//  ChainPersistence750.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainPersistence750: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Persistence"
        tag = "persistence750"
        chainImg = "chainPersistence"
        isDefault = false
        apiName = "persistence"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/750'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uxprt"
        bechAccountPrefix = "persistence"
        validatorPrefix = "persistencevaloper"
        grpcHost = ""
        lcdUrl = "https://rest.core.persistence.one/"
    }
    
}
