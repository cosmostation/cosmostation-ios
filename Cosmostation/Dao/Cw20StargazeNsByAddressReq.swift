//
//  Cw20StargazeNsByAddressReq.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/02/14.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct Cw20StargazeNsByAddressReq : Codable {
    let name: Name

    init(_ address: String) {
        self.name = Name.init(address)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}

public struct Name : Codable {
    var address: String?
    
    init(_ address: String) {
        self.address = address
    }
}
