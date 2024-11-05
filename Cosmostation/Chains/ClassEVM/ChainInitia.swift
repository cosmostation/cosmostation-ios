//
//  ChainInitia.swift
//  Cosmostation
//
//  Created by yongjoo jung on 7/5/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainInitia: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Initia"
        tag = "initia"
        logo1 = "chainInitia"
        apiName = "initia"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "uinit"
        bechAccountPrefix = "init"
        validatorPrefix = "initvaloper"
//        supportStaking = false
        grpcHost = ""
    }
    
    override func getCosmosfetcher() -> CosmosFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = InitiaFetcher.init(self)
        }
        return cosmosFetcher
    }
    
    func getInitiaFetcher() -> InitiaFetcher? {
        if (cosmosFetcher == nil) {
            cosmosFetcher = InitiaFetcher.init(self)
        }
        return cosmosFetcher as? InitiaFetcher
    }

}
