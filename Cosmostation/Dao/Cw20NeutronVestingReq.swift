//
//  Cw20NeutronVestingReq.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/05/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct Cw20NeutronVestingReq : Codable {
    var allocation: VestingReq?
    
    init(_ address: String) {
        self.allocation = VestingReq.init(address)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}

public struct VestingReq : Codable {
    var address: String?
    
    init(_ address: String) {
        self.address = address
    }
}
