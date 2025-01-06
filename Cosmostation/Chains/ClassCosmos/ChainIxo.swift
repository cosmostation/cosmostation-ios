//
//  ChainIxo.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainIxo: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Impact Hub"
        tag = "ixo118"
        logo1 = "chainIxo"
        apiName = "ixo"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uixo"
        bechAccountPrefix = "ixo"
        validatorPrefix = "ixovaloper"
        grpcHost = "grpc-ixo.cosmostation.io"
        lcdUrl = "https://lcd-ixo.cosmostation.io/"
    }
}
