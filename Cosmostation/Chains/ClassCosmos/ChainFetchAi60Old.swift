//
//  ChainFetchAi60Old.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/11/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainFetchAi60Old: ChainFetchAi  {
    
    override init() {
        super.init()
        
        isDefault = false
        tag = "fetchai60_Old"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/X")
    }
    
}
