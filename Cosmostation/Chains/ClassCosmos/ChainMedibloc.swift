//
//  ChainMedibloc.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainMedibloc: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Medibloc"
        tag = "medibloc371"
        chainImg = "chainMedibloc"
        apiName = "medibloc"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/371'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "umed"
        bechAccountPrefix = "panacea"
        validatorPrefix = "panaceavaloper"
        grpcHost = ""
        lcdUrl = "https://lcd-medibloc.imperator.co/"
    }
}

