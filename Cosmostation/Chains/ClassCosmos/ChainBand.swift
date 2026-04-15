//
//  ChainBand.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBand: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Band"
        tag = "band494"
        chainImg = "chainBand"
        apiName = "band"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/494'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uband"
        bechAccountPrefix = "band"
        validatorPrefix = "bandvaloper"
        grpcHost = ""
        lcdUrl = "https://laozi1.bandchain.org/api/"
    }
    
}
