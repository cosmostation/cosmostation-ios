//
//  ChainOrai.swift
//  Cosmostation
//
//  Created by 차소민 on 11/12/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainOrai: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Orai Chain"
        tag = "orai118"
        logo1 = "chainOrai"
        apiName = "orai-chain"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "orai"
        bechAccountPrefix = "orai"
        validatorPrefix = "oraivaloper"
        grpcHost = "grpc.orai.pfc.zone"
        lcdUrl = "https://lcd.orai.io"
    }
}
