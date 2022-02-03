//
//  Cw20TransferReq.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/02/03.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation


public struct Cw20TransferReq : Codable {
    var transfer: TransferReq?
    
    init(_ recipient: String, _ amount: String) {
        self.transfer = TransferReq.init(recipient, amount)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
    
}


public struct TransferReq : Codable {
    var recipient: String?
    var amount: String?
    
    init(_ recipient: String, _ amount: String) {
        self.recipient = recipient
        self.amount = amount
    }
}
