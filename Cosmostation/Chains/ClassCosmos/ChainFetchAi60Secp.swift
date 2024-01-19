//
//  ChainFetchAi60Secp.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainFetchAi60Secp: ChainFetchAi  {
    
    override init() {
        super.init()
        
        isDefault = false
        tag = "fetchai60_Secp"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/0/X")
    }
    
}

