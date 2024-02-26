//
//  ChainPolygon.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2024/02/27.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainPolygon: EvmClass  {
    
    override init() {
        super.init()
        
        name = "Polygon"
        tag = "polygon60"
        logo1 = "chainPolygon"
        logo2 = "chainPolygon2"
        apiName = "polygon"
        
        coinSymbol = "MATIC"
        coinGeckoId = "polygon"
        coinLogo = "tokenMatic"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        evmRpcURL = "https://polygon-rpc.com"
        explorerURL = "https://polygonscan.com/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
        
    }
    
}
