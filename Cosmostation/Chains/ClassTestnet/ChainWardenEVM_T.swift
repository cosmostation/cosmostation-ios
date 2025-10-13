//
//  ChainWardenEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 5/22/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainWardenEVM_T: ChainWardenEVM  {
    
    override init() {
        super.init()
        
        name = "Warden Protocol Testnet"
        tag = "warden_T"
        chainImg = "chainWarden_T"
        isTestnet = true
        apiName = "warden-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "award"
        bechAccountPrefix = "warden"
        validatorPrefix = "wardenvaloper"
        grpcHost = "grpc.barra.wardenprotocol."
        lcdUrl = "https://api.barra.wardenprotocol.org/"
    
        supportEvm = true
        coinSymbol = "WARD"
        evmRpcURL = "https://evm.barra.wardenprotocol.org"
    }
}
