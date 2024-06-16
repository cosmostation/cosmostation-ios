//
//  ChainGovgen.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainGovgen: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Govgen"
        tag = "govgen118"
        logo1 = "chainGovgen"
        logo2 = "chainGovgen2"
        supportCosmos = true
        apiName = "govgen"
        
        stakeDenom = "ugovgen"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "govgen"
        validatorPrefix = "govgenvaloper"
        grpcHost = "grpc-govgen.cosmostation.io"
        
        initFetcher()
    }
}
