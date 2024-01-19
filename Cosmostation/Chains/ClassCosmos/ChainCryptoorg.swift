//
//  ChainCryptoorg.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCryptoorg: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Cronos POS"
        tag = "crypto-org394"
        logo1 = "chainCryptoorg"
        logo2 = "chainCryptoorg2"
        apiName = "crypto-org"
        stakeDenom = "basecro"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/394'/0'/0/X")
        bechAccountPrefix = "cro"
        validatorPrefix = "crocncl"
        
        grpcHost = "grpc-crypto-org.cosmostation.io"
    }
    
}

