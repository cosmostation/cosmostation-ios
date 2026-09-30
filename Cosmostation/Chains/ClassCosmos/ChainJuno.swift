//
//  ChainJuno.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainJuno: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Juno"
        tag = "juno118"
        chainImg = "chainJuno"
        apiName = "juno"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ujuno"
        bechAccountPrefix = "juno"
        validatorPrefix = "junovaloper"
        grpcHost = "grpc-juno.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-juno.mainnet.cosmoslabs.kr/"
    }
}
