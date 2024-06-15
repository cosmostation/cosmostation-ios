//
//  ChainAlthea118.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/05.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAlthea118: BaseChain {
    
    override init() {
        super.init()
        
        name = "Althea"
        tag = "althea118"
        logo1 = "chainAlthea"
        logo2 = "chainAlthea2"
        isDefault = false
        supportCosmos = true
        apiName = "althea"
        
        stakeDenom = "aalthea"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "althea"
        validatorPrefix = "altheavaloper"
        grpcHost = "grpc-althea.cosmostation.io"
        
        initFetcher()
    }
}
/*
class ChainAlthea118: CosmosClass  {
    
    override init() {
        super.init()
        
        isDefault = false
        
        name = "Althea"
        tag = "althea118"
        logo1 = "chainAlthea"
        logo2 = "chainAlthea2"
        apiName = "althea"
        stakeDenom = "aalthea"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "althea"
        validatorPrefix = "altheavaloper"
        
        grpcHost = "grpc-althea.cosmostation.io"
    }
}
*/
