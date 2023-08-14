//
//  ChainKava60.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainKava60: BaseChain  {
    
    override init() {
        super.init()
        
        isDefault = false
        name = "Kava"
        id = "kava_2222-10"
        
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/60'/0'/0/X")
        accountPrefix = "kava"
        
        grpcHost = "grpc-kava.cosmostation.io"
    }
}
