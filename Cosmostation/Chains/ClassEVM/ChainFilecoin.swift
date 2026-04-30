//
//  ChainFilecoin.swift
//  Cosmostation
//
//  Created by 권혁준 on 4/27/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainFilecoin: BaseChain {
    
    override init() {
        super.init()
        
        name = "Filecoin"
        tag = "filecoin60"
        chainImg = "chainFilecoin"
        apiName = "filecoin"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "FIL"
        evmRpcURL = "https://filecoin.chainup.net/rpc/v1"
    }
}
