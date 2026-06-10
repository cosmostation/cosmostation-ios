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
        chainImg = "chainAssetmantle"
        apiName = "asset-mantle"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "umntl"
        bechAccountPrefix = "mantle"
        validatorPrefix = "mantlevaloper"
        grpcHost = "assetmantle-grpc.stakerhouse.com"
        lcdUrl = "https://assetmantle-api.polkachu.com/"
    }
}
