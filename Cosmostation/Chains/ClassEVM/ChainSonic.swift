//
//  ChainSonic.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/19/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSonic: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Sonic"
        tag = "sonic60"
        chainImg = "chainSonic"
        apiName = "sonic"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "S"
        evmRpcURL = "https://rpc.soniclabs.com"
    }
}
