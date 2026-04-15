//
//  ChainCheqd_T.swift
//  Cosmostation
//
//  Created by 권혁준 on 4/13/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainCheqd_T: ChainCheqd {
    
    override init() {
        super.init()
        
        name = "Cheqd Testnet"
        tag = "cheqd118_T"
        chainImg = "chainCheqd_T"
        isTestnet = true
        apiName = "cheqd-testnet"
        
        cosmosEndPointType = .UseLCD
        grpcHost = "grpc.cheqd.network:443"
        lcdUrl = "https://api.cheqd.network/"
    }
}
