//
//  OktHistory.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/10.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct OkHistoryRoot: Codable {
    var data: [OktHistoryData]?
}


public struct OktHistoryData: Codable {
    var transactionLists: [OktHistory]?
}

public struct OktHistory: Codable {
    var txId: String?
    var methodId: String?
    var blockHash: String?
    var height: String?
    var transactionTime: String?
    var from: String?
    var to: String?
    var amount: String?
    var transactionSymbol: String?
    var txFee: String?
    var state: String?
    var tokenId: String?
    var tokenContractAddress: String?
    var challengeStatus: String?
    var l1OriginHash: String?
}
