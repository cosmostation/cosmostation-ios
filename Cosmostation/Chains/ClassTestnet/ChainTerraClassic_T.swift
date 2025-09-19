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
        
        name = "Terra Classic Testnet"
        tag = "terraclassic330_T"
        chainImg = "chainTerraClassic_T"
        apiName = "terra-classic-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/330'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uluna"
        bechAccountPrefix = "terra"
        validatorPrefix = "terravaloper"
        grpcHost = "rebel-rpc.luncgoblins.com:443"
        lcdUrl = "https://rebel-lcd.luncgoblins.com/"
    }
}
