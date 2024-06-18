//
//  ChainBitcana.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBitcana: BaseChain {
    
    override init() {
        super.init()
        
        name = "Bitcanna"
        tag = "bitcanna118"
        logo1 = "chainBitcanna"
        logo2 = "chainBitcanna2"
        apiName = "bitcanna"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "ubcna"
        bechAccountPrefix = "bcna"
        validatorPrefix = "bcnavaloper"
        grpcHost = "grpc-bitcanna.cosmostation.io"
        
        initFetcher()
    }
    
}
