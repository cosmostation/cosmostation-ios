//
//  ChainSecret.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainSecret118: ChainSecret529  {
    
    override init() {
        super.init()
        
        isDefault = false
        tag = "secret118"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
    }
}
