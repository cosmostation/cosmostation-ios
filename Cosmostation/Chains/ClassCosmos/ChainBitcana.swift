//
//  ChainBitcana.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBitcana: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Bitcanna"
        id = "bitcanna118"
        logo1 = "chainBitcanna"
        logo2 = "chainBitcanna2"
        apiName = "bitcanna"
        stakeDenom = "ubcna"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "bcna"
        
        grpcHost = "grpc-bitcanna.cosmostation.io"
    }
    
}
