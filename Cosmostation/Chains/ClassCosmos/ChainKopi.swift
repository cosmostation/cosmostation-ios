//
//  ChainKopi.swift
//  Cosmostation
//
//  Created by 차소민 on 3/12/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainKopi: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Kopi"
        tag = "kopi118"
        logo1 = "chainKopi"
        apiName = "kopi"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "ukopi"
        bechAccountPrefix = "kopi"
        validatorPrefix = "kopivaloper"
        grpcHost = "kopi-grpc.stakerhouse.com"
        lcdUrl = "https://rest.kopi.money/"
    }
}
