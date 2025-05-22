//
//  ChainWardenEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/22/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainWardenEVM: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Warden Protocol"
        tag = "warden60"
        chainImg = "chainWarden_E"
        apiName = "warden"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .Unknown
        stakeDenom = "award"
        bechAccountPrefix = "warden"
        validatorPrefix = "wardenvaloper"
        grpcHost = ""
        lcdUrl = ""
    
        supportEvm = true
        coinSymbol = "WARD"
        evmRpcURL = ""
    }
}
