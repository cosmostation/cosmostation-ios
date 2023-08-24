//
//  ChainAssetMantle.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainAssetMantle: CosmosClass  {
    
    override init() {
        super.init()
        
        name = "AssetMantle"
        id = "assetmantle118"
        logo1 = "chainAssetmantle"
        logo2 = "chainAssetmantle2"
        apiName = "asset-mantle"
        stakeDenom = "umntl"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "mantle"
        
        grpcHost = "grpc-asset-mantle.cosmostation.io"
    }
    
}
