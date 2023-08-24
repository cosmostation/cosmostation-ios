//
//  RefAddress.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/08/24.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct RefAddress {
    var id: Int64 = -1
    var accountId: String = ""
    var chainId: String = ""
    var pubkeyType: Int64 = -1
    var dpAddress: String = ""
    var lastValue: String = "0"
    
    //using for generate new aacount
    init(_ accountId: String, _ chainId: String, _ pubkeyType: Int64,
         _ dpAddress: String, _ lastValue: String) {
        self.accountId = accountId
        self.chainId = chainId
        self.pubkeyType = pubkeyType
        self.dpAddress = dpAddress
        self.lastValue = lastValue
    }
    
    //db query
    init(_ id: Int64, _ accountId: String, _ chainId: String,
         _ pubkeyType: Int64, _ dpAddress: String, _ lastValue: String) {
        self.id = id
        self.accountId = accountId
        self.chainId = chainId
        self.pubkeyType = pubkeyType
        self.dpAddress = dpAddress
        self.lastValue = lastValue
    }
}
