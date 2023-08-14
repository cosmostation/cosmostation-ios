//
//  ChainCosmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainCosmos: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Cosmos"
        id = "cosmoshub-4"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
        accountPrefix = "cosmos"
    }
    
}
