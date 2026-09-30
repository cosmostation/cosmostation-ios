//
//  ChainKyve.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKyve: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Kyve"
        tag = "kyve118"
        chainImg = "chainKyve"
        apiName = "kyve"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ukyve"
        bechAccountPrefix = "kyve"
        validatorPrefix = "kyvevaloper"
        grpcHost = "grpc-kyve.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-kyve.mainnet.cosmoslabs.kr/"
    }
}
