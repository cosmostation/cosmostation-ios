//
//  ChainTeritori.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainTeritori: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Teritori"
        tag = "teritori118"
        logo1 = "chainTeritori"
        apiName = "teritori"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "utori"
        bechAccountPrefix = "tori"
        validatorPrefix = "torivaloper"
        grpcHost = ""
        lcdUrl = "https://teritori-api.polkachu.com/"
    }
}
