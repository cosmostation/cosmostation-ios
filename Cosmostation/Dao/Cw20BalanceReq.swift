//
//  Cw20BalanceQuery.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/29.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct Cw20BalaceReq : Codable {
    var balance: BalaceReq?
    
    init(_ address: String) {
        self.balance = BalaceReq.init(address)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}

public struct BalaceReq : Codable {
    var address: String?
    
    init(_ address: String) {
        self.address = address
    }
}
