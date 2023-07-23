//
//  ChainSui.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/19.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

struct ChainSui: BaseChain  {
    var name = "Sui"
    var id = ""
    
    
    var defaultKeyType = AccountKeyType(.SUI_Ed25519, "m/44'/784'/0'/0'/X'", true)
    
    func supportKeyTypes() -> Array<AccountKeyType> {
        return [defaultKeyType]
    }
}
