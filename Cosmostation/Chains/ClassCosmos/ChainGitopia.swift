//
//  ChainGitopia.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/28/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainGitopia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Gitopia"
        tag = "gitopia"
        chainImg = "chainGitopia"
        apiName = "gitopia"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ulore"
        bechAccountPrefix = "gitopia"
        validatorPrefix = "gitopiavaloper"
        grpcHost = "grpc-gitopia.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-gitopia.mainnet.cosmoslabs.kr/"
    }
}
