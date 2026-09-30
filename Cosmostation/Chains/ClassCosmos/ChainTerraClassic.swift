//
//  ChainTerra.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainTerraClassic: BaseChain  {
    
    override init() {
        super.init()
        
        name = "TerraClassic"
        tag = "terraclassic330"
        chainImg = "chainTerraClassic"
        apiName = "terra-classic"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/330'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uluna"
        bechAccountPrefix = "terra"
        validatorPrefix = "terravaloper"
        grpcHost = "grpc-terra-classic.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-terra-classic.mainnet.cosmoslabs.kr/"
    }
}
