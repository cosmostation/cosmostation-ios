//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava459: CosmosClass  {
    
    override init() {
        super.init()
        
        isDefault = false
        name = "Kava"
        tag = "kava459"
        logo1 = "chainKava"
        logo2 = "chainKava2"
        apiName = "kava"
        stakeDenom = "ukava"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/459'/0'/0/X")
        bechAccountPrefix = "kava"
        validatorPrefix = "kavavaloper"
        
        grpcHost = "grpc-kava.cosmostation.io"
    }
}

let KAVA_MAIN_DENOM = "ukava"
let KAVA_HARD_DENOM = "hard"
let KAVA_USDX_DENOM = "usdx"
let KAVA_SWAP_DENOM = "swp"

let KAVA_LCD = "https://lcd-kava.cosmostation.io/"
let KAVA_BASE_FEE = "12500"

let KAVA_CDP_IMG_URL        = ResourceBase + "kava/module/mint/";
let KAVA_HARD_POOL_IMG_URL  = ResourceBase + "kava/module/lend/";
