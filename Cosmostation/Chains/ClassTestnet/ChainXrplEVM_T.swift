//
//  ChainXrplEVM_T.swift
//  Cosmostation
//
//  Created by 차소민 on 3/24/25.
//  Copyright © 2025 wannabit. All rights reserved.
//

import Foundation

class ChainXrplEVM_T: ChainXrplEVM {
    override init() {
        super.init()
        
        name = "XRPL EVM Testnet"
        tag = "xrplevm60_T"
        logo1 = "chainXrplevm_T"
        isTestnet = true
        apiName = "xrplevm-testnet"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        supportEvm = true
        coinSymbol = "XRP"
        evmRpcURL = "https://rpc-office-evm.cosmostation.io/xrplevm-testnet/"
    }
}
