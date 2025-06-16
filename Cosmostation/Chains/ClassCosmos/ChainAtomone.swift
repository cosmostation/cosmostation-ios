//
//  ChainAtomone.swift
//  Cosmostation
//
//  Created by 차소민 on 10/2/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainAtomone: BaseChain {
    
    override init() {
        super.init()
        
        name = "Atomone"
        tag = "atomone118"
        chainImg = "chainAtomone"
        apiName = "atomone"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uatone"
        bechAccountPrefix = "atone"
        validatorPrefix = "atonevaloper"
        grpcHost = "grpc-atomone.cosmostation.io"
        lcdUrl = "https://lcd-atomone.cosmostation.io/"
    }
    
    override func getCosmosfetcher() -> CosmosFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = AtomoneFetcher.init(self)
        }
        return cosmosFetcher
    }
    
    func getAtomoneFetcher() -> AtomoneFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = AtomoneFetcher.init(self)
        }
        return cosmosFetcher as? AtomoneFetcher
    }
}
