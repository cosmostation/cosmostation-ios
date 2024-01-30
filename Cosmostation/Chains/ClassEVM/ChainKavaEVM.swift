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
        
        name = "Kava EVM"
        tag = "kavaEvm60"
        logo1 = "chainKava"
        logo2 = "chainKava2"
        apiName = "kava"
        
        coinSymbol = "KAVA"
        coinGeckoId = "kava"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        rpcURL = "https://rpc-kava-app.cosmostation.io"
    }
}
