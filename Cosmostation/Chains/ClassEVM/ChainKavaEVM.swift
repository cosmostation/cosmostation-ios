//
//  ChainKava_EVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava_EVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Kava"
        tag = "kavaEvm60"
        logo1 = "chainKava"
        logo2 = "chainKava2"
        apiName = "kava"
        stakeDenom = "ukava"
        
        //for EVM tx and display
        coinSymbol = "KAVA"
        coinGeckoId = "kava"
        coinLogo = "tokenKava"

        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "kava"
        validatorPrefix = "kavavaloper"
        
        grpcHost = "grpc-kava.cosmostation.io"
        rpcURL = "https://rpc-kava-app.cosmostation.io"
    }
}
