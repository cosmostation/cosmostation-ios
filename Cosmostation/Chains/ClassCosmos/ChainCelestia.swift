//
//  ChainCelestia.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCelestia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Celestia"
        tag = "celestia118"
        apiName = "celestia"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "utia"
        bechAccountPrefix = "celestia"
        validatorPrefix = "celestiavaloper"
        grpcHost = "grpc-celestia.cosmostation.io"
        lcdUrl = "https://lcd-celestia.cosmostation.io/"
    }
}
