//
//  ChainSelf.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation


class ChainSelf: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Self Chain"
        tag = "selfchain"
        logo1 = "chainSelf"
        apiName = "selfchain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uslf"
        bechAccountPrefix = "self"
        validatorPrefix = "selfvaloper"
        grpcHost = "grpc-selfchain.cosmostation.io"
        lcdUrl = "https://lcd-selfchain.cosmostation.io/"
    }
}
