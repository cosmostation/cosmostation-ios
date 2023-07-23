//
//  ChainKava.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

struct ChainKava: BaseChain  {
    var name = "Kava"
    var id = "kava_2222-10"
    
    
    var defaultKeyType0 = AccountKeyType(.ETH_Keccak256, "m/44'/60'/0'/0/X", true)
    var defaultKeyType1 = AccountKeyType(.COSMOS_Secp256k1, "m/44'/459'/0'/0/X", true)
    var legacyKeyType0 = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X", false)
    
    func supportKeyTypes() -> Array<AccountKeyType> {
        return [defaultKeyType0, defaultKeyType1, legacyKeyType0]
    }
}
