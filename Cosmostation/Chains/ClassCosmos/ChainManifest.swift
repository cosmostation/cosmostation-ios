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
        chainImg = "chainManifest"
        apiName = "manifest"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "upoa"
        bechAccountPrefix = "manifest"
        validatorPrefix = "manifestvaloper"
        grpcHost = "grpc-manifest.mainnet.cosmoslabs.kr"
        lcdUrl = "https://lcd-manifest.mainnet.cosmoslabs.kr/"
    }
}
