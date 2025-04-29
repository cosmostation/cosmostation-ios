//
//  ChainSelf_T.swift
//  Cosmostation
//
//  Created by 차소민 on 3/20/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainSelf_T: ChainSelf {
 
    override init() {
        super.init()
        
        name = "SelfChain Testnet"
        tag = "selfchain_T"
        isTestnet = true
        apiName = "selfchain-testnet"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")

        
        cosmosEndPointType = .UseLCD
        stakeDenom = "uslf"
        bechAccountPrefix = "self"
        validatorPrefix = "selfvaloper"
        grpcHost = "grpc.testnet.selfchain.cosmostation.io"
        lcdUrl = "https://lcd.testnet.selfchain.cosmostation.io/"
    }
}
