//
//  ChainPolygon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/27.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainPolygon: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Polygon"
        tag = "polygon60"
        chainImg = "chainPolygon"
        apiName = "polygon"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "MATIC"
        evmRpcURL = "https://polygon-rpc.com"
    }
    
}
