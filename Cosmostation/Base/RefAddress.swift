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
    var accountId: Int64 = -1
    var chainId: String = ""
    var dpAddress: String = ""
    var lastValue: String = "0"
    var lastAmount: String = "0"
    
    //create
    init(_ accountId: Int64, _ chainId: String, _ dpAddress: String, _ lastValue: String, _ lastAmount: String) {
        self.accountId = accountId
        self.chainId = chainId
        self.dpAddress = dpAddress
        self.lastValue = lastValue
        self.lastValue = lastValue
    }
    
    //db query
    init(_ id: Int64, _ accountId: Int64, _ chainId: String, _ dpAddress: String, _ lastValue: String, _ lastAmount: String) {
        self.id = id
        self.accountId = accountId
        self.chainId = chainId
        self.dpAddress = dpAddress
        self.lastValue = lastValue
        self.lastValue = lastValue
    }
}
