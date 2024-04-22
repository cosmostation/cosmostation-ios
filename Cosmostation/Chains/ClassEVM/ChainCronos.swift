//
//  ChainCronos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 4/17/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class ChainCronos: EvmClass  {
    
    override init() {
        super.init()
        
        name = "Cronos"
        tag = "cronos60"
        logo1 = "chainCronos"
        logo2 = "chainCronos2"
        apiName = "cronos"
        
        coinSymbol = "CRO"
        coinGeckoId = "crypto-com-chain"
        coinLogo = "tokenCro"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        evmRpcURL = "https://evm.cronos.org"
        
    }
    
}
