//
//  ChainXion.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainXion: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Xion"
        tag = "xion"
        chainImg = "chainXion"
        apiName = "xion"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uxion"
        bechAccountPrefix = "xion"
        validatorPrefix = "xionvaloper"
        grpcHost = ""
        lcdUrl = "https://xion-api.polkachu.com/"
    }
}
