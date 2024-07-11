//
//  ChainArtelaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainArtelaEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Artela"
        tag = "artela60"
        logo1 = "chainArtela"
        apiName = "artela"
        accountKeyType = AccountKeyType(.ARTELA_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "aart"
        bechAccountPrefix = "art"
        validatorPrefix = "artvaloper"
        grpcHost = ""
        
        
        supportEvm = true
        coinSymbol = "ART"
        coinGeckoId = ""
        coinLogo = "tokenArt"
        evmRpcURL = ""
    }
}
