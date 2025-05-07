//
//  ChainBitsong.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/01.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainBitsong: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Bitsong"
        tag = "bitsong639"
        chainImg = "chainBitsong"
        apiName = "bitsong"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/639'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubtsg"
        bechAccountPrefix = "bitsong"
        validatorPrefix = "bitsongvaloper"
        grpcHost = ""
        lcdUrl = "https://lcd.explorebitsong.com/"
    }
    
}
