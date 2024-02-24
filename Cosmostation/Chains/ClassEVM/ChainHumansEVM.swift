//
//  ChainHumansEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2/22/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainHumansEVM: EvmClass  {
    
    override init() {
        super.init()
        
        supportCosmos = true
        
        name = "Humans"
        tag = "humans60"
        logo1 = "chainHumans"
        logo2 = "chainHumans2"
        apiName = "humans"
        stakeDenom = "aheart"
        
        //for EVM tx and display
        coinSymbol = "HEART"
        coinGeckoId = "humans-ai"
        coinLogo = "tokenHeart"

        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        bechAccountPrefix = "human"
        validatorPrefix = "humanvaloper"
        
        grpcHost = "grpc-humans.cosmostation.io"
        rpcURL = "https://rpc-humans-evm.cosmostation.io"
//        rpcURL = "https://evm.humans.posthuman.digital"
        explorerURL = "https://www.mintscan.io/humans/"
        addressURL = explorerURL + "address/%@"
        txURL = explorerURL + "tx/%@"
    }
}
