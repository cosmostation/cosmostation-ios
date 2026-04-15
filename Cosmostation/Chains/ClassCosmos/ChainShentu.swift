//
//  ChainShentu.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainShentu: BaseChain {
    
    override init() {
        super.init()
        
        name = "Shentu"
        tag = "shentu118"
        chainImg = "chainShentu"
        apiName = "shentu"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uctk"
        bechAccountPrefix = "shentu"
        validatorPrefix = "shentuvaloper"
        grpcHost = ""
        lcdUrl = "https://shentu-api.polkachu.com/"
    }
    
}
