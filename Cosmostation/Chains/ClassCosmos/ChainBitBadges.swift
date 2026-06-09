//
//  ChainBitBadges.swift
//  Cosmostation
//
//  Created by 권혁준 on 5/1/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainBitBadges: BaseChain {
    
    override init() {
        super.init()
        
        name = "BitBadges"
        tag = "bitbadges118"
        chainImg = "chainBitBadges"
        apiName = "bitbadges"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "ubadge"
        bechAccountPrefix = "bb"
        validatorPrefix = "bbvaloper"
        grpcHost = "grpc.bitbadges.io"
        lcdUrl = "https://lcd.bitbadges.io/"
    }
}
