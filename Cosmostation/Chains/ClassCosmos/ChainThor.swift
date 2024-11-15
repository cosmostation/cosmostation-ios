//
//  ChainThor.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/15/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainThor: BaseChain {
    
    override init() {
        super.init()
        
        name = "ThorChain"
        tag = "thor"
        logo1 = "chainThor"
        apiName = "thorchain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/931'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "rune"
        bechAccountPrefix = "thor"
        validatorPrefix = "thorvaloper"
        supportStaking = false
        grpcHost = ""
        lcdUrl = "https://thornode.ninerealms.com/"
    }
}
