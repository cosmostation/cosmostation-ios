//
//  ChainOkt996Secp.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/07.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

class ChainOkt996Secp: ChainOkt996Keccak {
    
    override init() {
        super.init()
        
        name = "OKT"
        tag = "okt996_Secp"
        chainImg = "chainOkt"
        isDefault = false
        apiName = "okc"
        accountKeyType = AccountKeyType(.COSMOS_Secp256k1, "m/44'/996'/0'/0/X")
    }
    
    override func setInfoWithPrivateKey(_ priKey: Data) {
        privateKey = priKey
        publicKey = KeyFac.getPubKeyFromPrivateKey(privateKey!, accountKeyType.pubkeyType)
        bechAddress = KeyFac.getAddressFromPubKey(publicKey!, accountKeyType.pubkeyType, bechAccountPrefix)
        evmAddress = KeyFac.convertBech32ToEvm(bechAddress!)
    }
}
