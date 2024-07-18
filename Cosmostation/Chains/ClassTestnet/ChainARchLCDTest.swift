//
//  ChainARchLCDTest.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/16/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation


class ChainARchLCDTest: BaseChain  {
    
    override init() {
        super.init()
        
        name = "LCDArchway"
        tag = "archTTTTway"
        logo1 = "chainArchway"
        apiName = "archway"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosLcd = true
        stakeDenom = "aarch"
        bechAccountPrefix = "archway"
        validatorPrefix = "archwayvaloper"
        supportCw20 = true
        supportCw721 = true
        lcdUrl = "https://lcd-archway.cosmostation.io/"
    }
}
