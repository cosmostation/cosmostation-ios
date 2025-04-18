//
//  ChainC4E.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainC4E: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Chain4Energy"
        tag = "chain4energy"
        apiName = "chain4energy"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uc4e"
        bechAccountPrefix = "c4e"
        validatorPrefix = "c4evaloper"
        grpcHost = "grpc.c4e.nodestake.top:443"
        lcdUrl = "https://lcd.c4e.io/"
    }
    
}
