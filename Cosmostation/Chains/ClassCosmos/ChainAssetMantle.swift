//
//  ChainAssetMantle.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainAssetMantle: BaseChain  {
    
    override init() {
        super.init()
        
        name = "AssetMantle"
        tag = "assetmantle118"
        logo1 = "chainAssetmantle"
        apiName = "asset-mantle"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseGRPC
        stakeDenom = "umntl"
        bechAccountPrefix = "mantle"
        validatorPrefix = "mantlevaloper"
        grpcHost = "grpc-asset-mantle.cosmostation.io"
        lcdUrl = "https://lcd-asset-mantle.cosmostation.io/"
    }
}
