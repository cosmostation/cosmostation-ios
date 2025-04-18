//
//  ChainPryzm.swift
//  Cosmostation
//
//  Created by yongjoo jung on 9/20/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation


class ChainPryzm: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Pryzm"
        tag = "pryzm"
        apiName = "pryzm"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "upryzm"
        bechAccountPrefix = "pryzm"
        validatorPrefix = "pryzmvaloper"
        grpcHost = "grpc.pryzm.zone:443"
        lcdUrl = "https://api.pryzm.zone/"
    }
}
