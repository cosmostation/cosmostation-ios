//
//  ChainKava_Legacy.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/13.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava_Legacy: BaseChain  {
    
    override init() {
        super.init()
        
        name = "Kava"
        id = "kava_2222-10"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X")
    }
}
