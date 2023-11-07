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
    var chainTag: String = ""
    var dpAddress: String = ""
    var evmAddress: String = ""
    var lastMainValue: String = "0"         // last coins total USD value
    var lastMainAmount: String = "0"        // last main denom amount
    var lastTokenValue: String = "0"        // last tokens total USD value
    var lastCoinCnt: Int64 = 0              // last coin type counts
    
    //create
    init(_ accountId: Int64, _ chainTag: String, _ dpAddress: String, _ evmAddress: String,
         _ lastMainValue: String? = "0", _ lastMainAmount: String? = "0", _ lastTokenValue: String? = "0", _ lastCoinCnt: Int? = 0) {
        self.accountId = accountId
        self.chainTag = chainTag
        self.dpAddress = dpAddress
        self.evmAddress = evmAddress
        if (lastMainValue != nil && !lastMainValue!.isEmpty) {
            self.lastMainValue = lastMainValue!
        }
        if (lastMainAmount != nil && !lastMainAmount!.isEmpty) {
            self.lastMainAmount = lastMainAmount!
        }
        if (lastTokenValue != nil && !lastTokenValue!.isEmpty) {
            self.lastTokenValue = lastTokenValue!
        }
        if (lastCoinCnt != nil) {
            self.lastCoinCnt = Int64(lastCoinCnt!)
        }
    }
    
    //db query
    init(_ id: Int64, _ accountId: Int64, _ chainTag: String, _ dpAddress: String, _ evmAddress: String, _ lastMainValue: String?, _ lastMainAmount: String?, _ lastTokenValue: String?, _ lastCoinCnt: Int64?) {
        self.id = id
        self.accountId = accountId
        self.chainTag = chainTag
        self.dpAddress = dpAddress
        self.evmAddress = evmAddress
        if (lastMainValue != nil && !lastMainValue!.isEmpty) {
            self.lastMainValue = lastMainValue!
        }
        if (lastMainAmount != nil && !lastMainAmount!.isEmpty) {
            self.lastMainAmount = lastMainAmount!
        }
        if (lastTokenValue != nil && !lastTokenValue!.isEmpty) {
            self.lastTokenValue = lastTokenValue!
        }
        if (lastCoinCnt != nil) {
            self.lastCoinCnt = lastCoinCnt!
        }
    }
    
    func lastUsdValue() -> NSDecimalNumber {
        return NSDecimalNumber(string: lastMainValue).adding(NSDecimalNumber(string: lastTokenValue), withBehavior: handler6)
    }
}
