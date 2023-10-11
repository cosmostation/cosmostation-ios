//
//  ChainNeutron.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainNeutron: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "Neutron"
        tag = "neutron118"
        logo1 = "chainNeutron"
        logo2 = "chainNeutron2"
        apiName = "neutron"
        stakeDenom = "untrn"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "neutron"
        supportStaking = false
        
        grpcHost = "grpc-neutron.cosmostation.io"
    }
}
