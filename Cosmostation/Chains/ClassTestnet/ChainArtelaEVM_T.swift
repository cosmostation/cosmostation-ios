//
//  ChainArtelaEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainArtelaEVM_T: ChainArtelaEVM  {
    
    override init() {
        super.init()
        
        name = "Artela Testnet"
        tag = "artela60_T"
        logo1 = "chainArtela_T"
        isTestnet = true
        apiName = "artela-testnet"
        accountKeyType = AccountKeyType(.ARTELA_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uart"
        bechAccountPrefix = "art"
        validatorPrefix = "artvaloper"
        grpcHost = "grpc-office-artela.cosmostation.io"
        
        
        supportEvm = true
        coinSymbol = "ART"
        coinGeckoId = ""
        coinLogo = "tokenArt"
        evmRpcURL = "https://rpc-office-evm.cosmostation.io/artela-testnet/"
    }
}
