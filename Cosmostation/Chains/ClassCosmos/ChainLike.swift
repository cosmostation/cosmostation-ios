//
//  ChainLike.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainLike: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Likecoin"
        tag = "likecoin118"
        logo1 = "chainLike"
        logo2 = "chainLike2"
        supportCosmos = true
        apiName = "likecoin"
        
        stakeDenom = "nanolike"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "like"
        validatorPrefix = "likevaloper"
        grpcHost = "grpc-likecoin.cosmostation.io"
        
        initFetcher()
    }
}
