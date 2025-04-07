//
//  ChainManifest.swift
//  Cosmostation
//
//  Created by 차소민 on 3/25/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainManifest: BaseChain {
    override init() {
        super.init()
        
        name = "Manifest"
        tag = "manifest118"
        logo1 = "chainManifest"
        apiName = "manifest"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "upoa"
        bechAccountPrefix = "manifest"
        validatorPrefix = "manifestvaloper"
        grpcHost = "https://manifest-grpc.liftedinit.app"
        lcdUrl = "https://nodes.liftedinit.app/manifest/api/"
    }
}
