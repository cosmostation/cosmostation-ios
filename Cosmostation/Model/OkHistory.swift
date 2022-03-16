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
    var detail_msg: String?
    var data: OKHistoryData?
    
    init(_ dictionary: NSDictionary?) {
        self.code = dictionary?["code"] as? Int64
        self.msg = dictionary?["msg"] as? String
        self.detail_msg = dictionary?["detail_msg"] as? String
        if let rawData = dictionary?["data"] as? NSDictionary {
            self.data = OKHistoryData.init(rawData)
        }
    }
}


public struct OKHistoryData {
    var total: Int64 = 0
    var hits = Array<OKHistoryHit>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawTotal = dictionary?["total"] as? Int64 {
            self.total = rawTotal
        }
        if let rawHits = dictionary?["hits"] as? Array<NSDictionary>  {
            for rawHit in rawHits {
                self.hits.append(OKHistoryHit.init(rawHit))
            }
        }
    }
}


public struct OKHistoryHit {
    var hash: String?
    var blocktime: Int64?
    var blockHeight: Int64?
    var fromEvmAddress: String?
    var toEvmAddress: String?
    var transactionDataType: String = "Unknown"
    
    init(_ dictionary: NSDictionary?) {
        self.hash = dictionary?["hash"] as? String
        self.blocktime = dictionary?["blockTimeU0"] as? Int64
        self.blockHeight = dictionary?["blockHeight"] as? Int64
        self.fromEvmAddress = dictionary?["fromEvmAddress"] as? String
        self.toEvmAddress = dictionary?["toEvmAddress"] as? String
        
        if let rawTransactionData = dictionary?["transactionData"] as? Array<NSDictionary>, let rawType = rawTransactionData[0].object(forKey: "type") as? String  {
            self.transactionDataType = String(rawType.split(separator: "/").last!).replacingOccurrences(of: "Msg", with: "")
        }
    }
}
