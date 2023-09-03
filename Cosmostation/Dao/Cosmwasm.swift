//
//  Cosmwasm.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

//Cw20 balance query
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

public struct Cw20BalaceRes : Codable {
    var balance: String?
}
