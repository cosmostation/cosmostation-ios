//
//  ChainKavaEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKavaEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Kava"
        tag = "kava60"
        logo1 = "chainKavaEvm"
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
        evmRpcURL = "https://rpc-kava-app.cosmostation.io"
        explorerURL = "https://kavascan.io/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
    }
}
