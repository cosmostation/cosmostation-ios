//
//  ChainAirchains_T.swift
//  Cosmostation
//
//  Created by 권혁준 on 12/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainAirchains_T: ChainAirchains  {
    
    override init() {
        super.init()
        
        name = "Airchains Testnet"
        tag = "airchains_T"
        chainImg = "chainAirchains_T"
        isTestnet = true
        apiName = "airchains-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uamf"
        bechAccountPrefix = "air"
        validatorPrefix = "airvaloper"
        grpcHost = "airchains-testnet-grpc.cosmonautstakes.com:14190"
        lcdUrl = "https://airchains.api.t.stavr.tech/"
    }
}
