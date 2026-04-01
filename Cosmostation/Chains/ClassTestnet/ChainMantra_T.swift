//
//  ChainMantra_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainMantra_T: ChainMantra  {
    
    override init() {
        super.init()
        
        name = "Mantra Testnet"
        tag = "mantra_T"
        chainImg = "chainMantra_T"
        isTestnet = true
        isDefault = false
        apiName = "mantra-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uom"
        bechAccountPrefix = "mantra"
        validatorPrefix = "mantravaloper"
        grpcHost = "grpc.dukong.mantrachain.io"
        lcdUrl = "https://api.dukong.mantrachain.io/"
    }
}

