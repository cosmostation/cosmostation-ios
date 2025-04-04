//
//  ChainLombard_T.swift
//  Cosmostation
//
//  Created by 차소민 on 3/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainLombard_T: ChainLombard  {
    
    override init() {
        super.init()
        
        name = "Lombard Testnet"
        tag = "lombard118_T"
        logo1 = "chainLombard_T"
        isTestnet = true
        apiName = "lombard-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ulom"
        bechAccountPrefix = "lom"
        validatorPrefix = "lomvaloper"
        grpcHost = "grpc.testnet.lombard.cosmostation.io"
        lcdUrl = "https://lcd.testnet.lombard.cosmostation.io/"
    }
}
