//
//  ChainFantom.swift
//  Cosmostation
//
//  Created by 차소민 on 11/12/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainFantom: BaseChain {
    
    override init() {
        super.init()
        
        name = "Fantom"
        tag = "fantom60"
        logo1 = "chainFantom"
        apiName = "fantom"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "FTM"
        coinGeckoId = "fantom"
        coinLogo = "tokenFantom"
        evmRpcURL = "https://fantom.drpc.org"
    }
}
