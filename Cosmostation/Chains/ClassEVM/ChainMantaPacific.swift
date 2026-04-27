//
//  ChainMantaPacific.swift
//  Cosmostation
//
//  Created by 권혁준 on 4/27/26.
//  Copyright © 2026 wannabit. All rights reserved.
//

import Foundation

class ChainMantaPacific: BaseChain {
    
    override init() {
        super.init()
        
        name = "Manta Pacific"
        tag = "mantapacific60"
        chainImg = "chainMantaPacific"
        apiName = "manta-pacific"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        evmRpcURL = "https://pacific-rpc.manta.network/http"
    }
}
