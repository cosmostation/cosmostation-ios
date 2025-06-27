//
//  ChainXrplEVM.swift
//  Cosmostation
//
//  Created by 차소민 on 3/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainXrplEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "XRPL EVM Sidechain"
        tag = "xrplevm60"
        chainImg = "chainXrplside_E"
        apiName = "xrplevm"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        supportEvm = true
        coinSymbol = "XRP"
        evmRpcURL = "https://rpc.evm.xrplevm.mainnet.cosmostation.io"
    }
}
