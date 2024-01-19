//
//  ChainPersistence750.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/23.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainPersistence750: ChainPersistence118  {
    
    override init() {
        super.init()
        
        isDefault = false
        tag = "persistence750"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/750'/0'/0/X")
    }
    
}
