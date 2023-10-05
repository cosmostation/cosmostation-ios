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
    var lastMainValue: String = "0"        // last coins total USD value
    var lastMainAmount: String = "-1"        // last main denom amount
    var lastTokenValue: String = "0"       // last tokens total USD value
    var lastCoinCnt: Int64 = 0               // last coin type counts
    
    //create
    init(_ accountId: Int64, _ chainTag: String, _ dpAddress: String, _ lastMainValue: String, _ lastMainAmount: String, _ lastTokenValue: String, _ lastCoinCnt: Int64) {
        self.accountId = accountId
        self.chainTag = chainTag
        self.dpAddress = dpAddress
        self.lastMainValue = lastMainValue
        self.lastMainAmount = lastMainAmount
        self.lastTokenValue = lastTokenValue
        self.lastCoinCnt = lastCoinCnt
    }
    
    //db query
    init(_ id: Int64, _ accountId: Int64, _ chainTag: String, _ dpAddress: String, _ lastMainValue: String?, _ lastMainAmount: String?, _ lastTokenValue: String?, _ lastCoinCnt: Int64?) {
        self.id = id
        self.accountId = accountId
        self.chainTag = chainTag
        self.dpAddress = dpAddress
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
        
        
//        if let alastMainValue = lastMainValue {
//            self.lastMainValue = alastMainValue
//        }
//        if let alastMainAmount = lastMainAmount {
//            self.lastMainAmount = alastMainAmount
//        }
//        if let alastTokenValue = lastTokenValue {
//            self.lastTokenValue = alastTokenValue
//        }
    }
    
    func lastUsdValue() -> NSDecimalNumber {
        return NSDecimalNumber(string: lastMainValue).adding(NSDecimalNumber(string: lastTokenValue), withBehavior: handler6)
    }
}
