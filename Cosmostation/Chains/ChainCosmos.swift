//
//  ChainCosmos.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

struct ChainCosmos: BaseChain  {
    var name = "Cosmos"
    var id = "cosmoshub-4"
    
    
    var defaultKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/118'/0'/0/X", true)
    
    func supportKeyTypes() -> Array<AccountKeyType> {
        return [defaultKeyType]
    }
}
