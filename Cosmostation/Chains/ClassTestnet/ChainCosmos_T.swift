//
//  ChainCosmos_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCosmos_T: BaseChain {
    
    override init() {
        super.init()
        
        name = "Cosmos Testnet"
        tag = "cosmos118_T"
        isTestnet = true
        apiName = "cosmos-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uatom"
        bechAccountPrefix = "cosmos"
        validatorPrefix = "cosmosvaloper"
        grpcHost = "grpc-office.cosmostation.io"
        lcdUrl = "https://rest.sentry-01.theta-testnet.polypore.xyz/"
    }
}
