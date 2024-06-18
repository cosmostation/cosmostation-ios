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
        logo1 = "chainEthereum"
        logo2 = "chainEthereum2"
        apiName = "ethereum"
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
        
        
        supportEvm = true
        coinSymbol = "ETH"
        coinGeckoId = "ethereum"
        coinLogo = "tokenEth"
        evmRpcURL = "https://rpc-ethereum-evm.cosmostation.io/rpc"
        
        initFetcher()
    }
}
/*
 class ChainEthereum: EvmClass  {
 
 override init() {
 super.init()
 
 name = "Ethereum"
 tag = "ethereum60"
 logo1 = "chainEthereum"
 logo2 = "chainEthereum2"
 apiName = "ethereum"
 
 coinSymbol = "ETH"
 coinGeckoId = "ethereum"
 coinLogo = "tokenEth"
 
 accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X")
 
 evmRpcURL = "https://rpc-ethereum-evm.cosmostation.io/rpc"
 
 }
 
 }
 */
