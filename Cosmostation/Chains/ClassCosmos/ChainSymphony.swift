//
//  ChainSymphony.swift
//  Cosmostation
//
//  Created by 권혁준 on 6/10/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainSymphony: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Symphony"
        tag = "symphony118"
        chainImg = "chainSymphony"
        apiName = "symphony"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "note"
        bechAccountPrefix = "symphony"
        validatorPrefix = "symphonyvaloper"
        grpcHost = "symphony-grpc.cogwheel.zone:443"
        lcdUrl = "https://api-m.symphony.vinjan-inc.com/"
    }
    
}
