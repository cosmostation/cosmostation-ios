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
        
        name = "SelfChain"
        tag = "selfchain"
        chainImg = "chainSelf"
        apiName = "selfchain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uslf"
        bechAccountPrefix = "self"
        validatorPrefix = "selfvaloper"
        grpcHost = "selfchain-mainnet.grpc.stakevillage.net"
        lcdUrl = "https://api.selfchain.io/"
    }
}
