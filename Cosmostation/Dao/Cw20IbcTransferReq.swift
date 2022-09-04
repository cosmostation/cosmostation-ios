//
//  Cw20IBCTransferReq.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/09/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation


public struct Cw20IbcTransferReq : Codable {
    var send: IbcSendReq?
    
    init(_ contract: String, _ amount: String, _ msg: String) {
        self.send = IbcSendReq.init(contract, amount, msg)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}


public struct IbcSendReq : Codable {
    var contract: String?
    var amount: String?
    var msg: String?
    
    init(_ contract: String, _ amount: String, _ msg: String) {
        self.contract = contract
        self.amount = amount
        self.msg = msg
    }
}
