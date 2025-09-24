//
//  ChainTerraClassic_T.swift
//  Cosmostation
//
//  Created by 권혁준 on 9/23/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainTerraClassic_T: ChainTerraClassic  {
    
    override init() {
        super.init()
        
        name = "Terra Classic Testnet"
        tag = "terraclassic330_T"
        chainImg = "chainTerraClassic_T"
        isTestnet = true
        apiName = "terra-classic-testnet"
        
        
        cosmosEndPointType = .UseLCD
        grpcHost = "rebel-rpc.luncgoblins.com"
        lcdUrl = "https://rebel-lcd.luncgoblins.com/"
    }
}

