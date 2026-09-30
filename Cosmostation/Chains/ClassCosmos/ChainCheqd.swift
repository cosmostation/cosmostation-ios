//
//  ChainCheqd.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCheqd: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Cheqd"
        tag = "cheqd118"
        chainImg = "chainCheqd"
        apiName = "cheqd"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ncheq"
        bechAccountPrefix = "cheqd"
        validatorPrefix = "cheqdvaloper"
        grpcHost = "grpc-cheqd.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-cheqd.mainnet.cosmoslabs.kr/"
    }
}
