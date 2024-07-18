//
//  ChainStarTest.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/18/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainStarTest: BaseChain {
    
    override init() {
        super.init()
        
        name = "Stargaze TTT"
        tag = "stargaze118asdsads"
        logo1 = "chainStargaze"
        apiName = "stargaze"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosLcd = true
        stakeDenom = "ustars"
        bechAccountPrefix = "stars"
        validatorPrefix = "starsvaloper"
        supportCw721 = true
        lcdUrl = "https://lcd-stargaze.cosmostation.io/"
    }
}
