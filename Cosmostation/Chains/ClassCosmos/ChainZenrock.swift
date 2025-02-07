//
//  ChainZenrock.swift
//  Cosmostation
//
//  Created by 차소민 on 2/5/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainZenrock: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Zenrock"
        tag = "zenrock118"
        logo1 = "chainZenrock"
        apiName = "zenrock"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")

        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "urock"
        bechAccountPrefix = "zen"
        validatorPrefix = "zenvaloper"
        grpcHost = "grpc.zenrock.nodestake.org"
        lcdUrl = "https://api.zenrock.nodestake.org/"
    }
    
    override func getCosmosfetcher() -> CosmosFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = ZenrockFetcher.init(self)
        }
        return cosmosFetcher
    }
    
    func getZenrockFetcher() -> ZenrockFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = ZenrockFetcher.init(self)
        }
        return cosmosFetcher as? ZenrockFetcher
    }

}
