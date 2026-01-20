//
//  ChainGnosis.swift
//  Cosmostation
//
//  Created by 권혁준 on 1/20/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainGnosis: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Gnosis"
        tag = "gnosis60"
        chainImg = "chainGnosis"
        apiName = "gnosis"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "xDAI"
        evmRpcURL = "https://rpc.gnosischain.com"
    }
}
