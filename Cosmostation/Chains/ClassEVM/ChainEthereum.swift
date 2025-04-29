//
//  ChainEthereum.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainEthereum: BaseChain {
    
    override init() {
        super.init()
        
        name = "Ethereum"
        tag = "ethereum60"
        apiName = "ethereum"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        evmRpcURL = "https://rpc-ethereum-evm.cosmostation.io/rpc"
    }
}
