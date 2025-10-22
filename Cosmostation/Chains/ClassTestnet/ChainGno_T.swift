//
//  ChainGno_T.swift
//  Cosmostation
//
//  Created by 차소민 on 1/8/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainGno_T: ChainGno {
    
    override init() {
        super.init()
        
        name = "Gno Testnet"
        tag = "gno118_T"
        chainImg = "chainGno_T"
        isTestnet = true
        apiName = "gno-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseRPC
        stakeDenom = "ugnot"
        bechAccountPrefix = "g"
        validatorPrefix = "gvaloper"
        grpcHost = ""
        lcdUrl = ""
        rpcUrl = "https://rpc.test9.testnets.gno.land"
    }
}
