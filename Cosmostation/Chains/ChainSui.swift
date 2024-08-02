//
//  ChainSui.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSui: BaseChain  {
    var address: String?
    
    override init() {
        super.init()
        
        name = "Sui"
        accountKeyType = AccountKeyType(.SUI_Ed25519, "m/44'/784'/0'/0'/X'")
        
        tag = ""
        logo1 = "chainSui"
        apiName = ""
        
        coinGeckoId = "sui"
        stakeDenom = "SUI"
        
        evmRpcURL = "https://sui-mainnet-us-2.cosmostation.io" //
    }
}

class ChainBitcoin: BaseChain {
    var address: String?

    override init() {
        super.init()
        
        accountKeyType = AccountKeyType(.BTC_Secp256k1, "m/44'/0'/0'/0/X")
        tag = ""
        logo1 = ""
        apiName = ""
        
        name = "Bitcoin"
        stakeDenom = "BTC"
        
    }
//    PATH_BTC_PARENTS                        = "M/44H/0H/0H/0";
//    PATH_BTC_FIRST                            = "M/44H/0H/0H/0/0H";
//    COIN_BTC                                = "BTC";
//     COIN_BTC_NAME                            = "Bitcoin";

}
