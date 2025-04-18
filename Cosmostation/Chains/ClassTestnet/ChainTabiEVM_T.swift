//
//  ChainTabiEVM_T.swift
//  Cosmostation
//
//  Created by yongjoo jung on 1/3/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainTabiEVM_T: ChainTabiEVM  {
    
    override init() {
        super.init()
        
        name = "TabiChain Testnet"
        tag = "tabi_T"
        isTestnet = true
        apiName = "tabichain-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        cosmosEndPointType = .UseLCD
        stakeDenom = "atabi"
        bechAccountPrefix = "tabis"
        validatorPrefix = "tabisvaloper"
        grpcHost = ""
        lcdUrl = "https://api.testnetv2.tabichain.com/"
    
        supportEvm = true
        coinSymbol = "TABI"
        evmRpcURL = "https://rpc.testnetv2.tabichain.com/"
    }
}
