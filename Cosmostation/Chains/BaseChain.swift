//
//  BaseChain.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/07/20.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation


protocol BaseChain {
    var name: String { get set }
    var id: String { get set }
    
}



struct AccountKeyType {
    var pubkeyType: PubKeyType!
    var hdPath: String!
    var isDefault: Bool!
    
    init(_ pubkeyType: PubKeyType!, _ hdPath: String!, _ isDefault: Bool) {
        self.pubkeyType = pubkeyType
        self.hdPath = hdPath
        self.isDefault = isDefault
    }
}

enum PubKeyType: Int {
    case ETH_Keccak256 = 0
    case COSMOS_Secp256k1 = 1
    case SUI_Ed25519 = 2
    case unknown = 99
}
