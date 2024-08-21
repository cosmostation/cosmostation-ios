//
//  ChainMantra_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 8/21/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainMantra_T: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Mantra Testnet"
        tag = "mantra_T"
        logo1 = "chainMantra_T"
        isTestnet = true
        apiName = "mantra-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uom"
        bechAccountPrefix = "mantra"
        validatorPrefix = "mantravaloper"
        grpcHost = "grpc-office-mantra.cosmostation.io"
    }
}

