//
//  ChainOkt996Keccak.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/09.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOkt996Keccak: ChainOkt60Keccak  {
    
    override init() {
        super.init()
        
        isDefault = false
        tag = "okt996_Keccak"
        
        accountKeyType = AccountKeyType(.ETH_Keccak256, "m/44'/996'/0'/0/X")
        bechAccountPrefix = "ex"
//        evmCompatible = false
    }
    
    override func setInfoWithSeed(_ seed: Data, _ lastPath: String) {
        super.setInfoWithSeed(seed, lastPath)
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        super.setInfoWithPrivateKey(priKey)
    }
}
