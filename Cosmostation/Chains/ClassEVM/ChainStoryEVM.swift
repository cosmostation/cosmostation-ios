//
//  ChainStoryEVM.swift
//  Cosmostation
//
//  Created by yongjoo jung on 12/12/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainStoryEVM: BaseChain {
    
    override init() {
        super.init()
        
        name = "Story"
        tag = "story"
        logo1 = "chainStory"
        apiName = "story"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "IP"
        coinGeckoId = ""
        coinLogo = "tokenIp"
        evmRpcURL = ""
    }
    
//    override func fetchBalances() {
//    }
//    
//    override func fetchData(_ id: Int64) {
//    }
}
