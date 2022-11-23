//
//  OkHistory.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/01/11.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation

public struct OkHistory {
    var code: Int64?
    var msg: String?
    var datas = Array<OKHistoryData>()
    
    init(_ dictionary: NSDictionary?) {
        self.code = dictionary?["code"] as? Int64
        self.msg = dictionary?["msg"] as? String
        if let rawDatas = dictionary?["data"] as? Array<NSDictionary> {
            rawDatas.forEach { rawData in
                datas.append(OKHistoryData.init(rawData))
            }
        }
    }
}

public struct OKHistoryData {
    var page: String?
    var limit: String?
    var totalPage: String?
    var chainFullName: String?
    var chainShortName: String?
    var transactionLists = Array<OKTransactionList>()
    
    init(_ dictionary: NSDictionary?) {
        self.page = dictionary?["page"] as? String
        self.limit = dictionary?["limit"] as? String
        self.totalPage = dictionary?["totalPage"] as? String
        self.chainFullName = dictionary?["chainFullName"] as? String
        self.chainShortName = dictionary?["chainShortName"] as? String
        if let rawLists = dictionary?["transactionLists"] as? Array<NSDictionary> {
            rawLists.forEach { rawList in
                transactionLists.append(OKTransactionList.init(rawList))
            }
        }
    }
}

public struct OKTransactionList {
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
    
    init(_ dictionary: NSDictionary?) {
        self.txId = dictionary?["txId"] as? String
        self.methodId = dictionary?["methodId"] as? String
        self.blockHash = dictionary?["blockHash"] as? String
        self.height = dictionary?["height"] as? String
        self.transactionTime = dictionary?["transactionTime"] as? String
        self.from = dictionary?["from"] as? String
        self.to = dictionary?["to"] as? String
        self.amount = dictionary?["amount"] as? String
        self.transactionSymbol = dictionary?["transactionSymbol"] as? String
        self.txFee = dictionary?["txFee"] as? String
        self.state = dictionary?["state"] as? String
        self.tokenId = dictionary?["tokenId"] as? String
        self.tokenContractAddress = dictionary?["tokenContractAddress"] as? String
        self.challengeStatus = dictionary?["challengeStatus"] as? String
        self.l1OriginHash = dictionary?["l1OriginHash"] as? String
    }
}
