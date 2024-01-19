//
//  ChainLum118.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainLum118: ChainLum880  {
    
    override init() {
        super.init()
        
        isDefault = false
        tag = "lum118"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
    }
    
}
