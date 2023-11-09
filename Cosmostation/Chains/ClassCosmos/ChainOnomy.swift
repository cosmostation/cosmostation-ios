//
//  ChainOnomy.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOnomy: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Onomy"
        tag = "onomy-protocol118"
        logo1 = "chainOnomy"
        logo2 = "chainOnomy2"
        apiName = "onomy-protocol"
        stakeDenom = "anom"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        bechAccountPrefix = "onomy"
        
        grpcHost = "grpc-onomy-protocol.cosmostation.io"
    }
}
