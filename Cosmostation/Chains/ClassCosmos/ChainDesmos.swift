//
//  ChainDesmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainDesmos: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Desmos"
        tag = "desmos852"
        chainImg = "chainDesmos"
        apiName = "desmos"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/852'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "udsm"
        bechAccountPrefix = "desmos"
        validatorPrefix = "desmosvaloper"
        grpcHost = ""
        lcdUrl = "https://desmos-rest.staketab.org/"
    }
    
}
