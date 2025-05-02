//
//  ChainFirma.swift
//  Cosmostation
//
//  Created by 차소민 on 11/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainFirma: BaseChain  {
    
    override init() {
        super.init()
        
        name = "FirmaChain"
        tag = "firmachain7777777"
        chainImg = "chainFirma"
        apiName = "firmachain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/7777777'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ufct"
        bechAccountPrefix = "firma"
        validatorPrefix = "firmavaloper"
        grpcHost = ""
        lcdUrl = "https://lcd-mainnet.firmachain.dev:1317"
    }
}
