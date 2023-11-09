//
//  ChainMedibloc.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainMedibloc: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Medibloc"
        tag = "medibloc371"
        logo1 = "chainMedibloc"
        logo2 = "chainMedibloc2"
        apiName = "medibloc"
        stakeDenom = "umed"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/371'/0'/0/X")
        bechAccountPrefix = "panacea"
        
        grpcHost = "grpc-medibloc.cosmostation.io"
    }
}

