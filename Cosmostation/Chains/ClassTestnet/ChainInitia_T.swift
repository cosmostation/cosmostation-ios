//
//  ChainInitia_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainInitia_T: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Initia"
        tag = "initia_T"
        logo1 = "chainInitia_T"
        apiName = "initia-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportCosmosGrpc = true
        stakeDenom = "uinit"
        bechAccountPrefix = "init"
        validatorPrefix = "initvaloper"
        supportStaking = false
        grpcHost = "grpc-office-initia.cosmostation.io"
    }
}
