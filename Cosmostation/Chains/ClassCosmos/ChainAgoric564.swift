//
//  ChainAgoric564.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/23/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAgoric564: BaseChain {
    
    override init() {
        super.init()
        
        name = "Agoric"
        tag = "agoric459"
        chainImg = "chainAgoric"
        apiName = "agoric"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/564'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubld"
        bechAccountPrefix = "agoric"
        validatorPrefix = "agoricvaloper"
        grpcHost = ""
        lcdUrl = "https://agoric-api.polkachu.com/"
    }
}
