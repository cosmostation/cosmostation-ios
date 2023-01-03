//
//  Cw20IcnsByAddressReq.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/01/02.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct Cw20IcnsByAddressReq : Codable {
    var primary_name: PrimaryName?

    init(_ address: String) {
        self.primary_name = PrimaryName.init(address)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}

public struct PrimaryName : Codable {
    var address: String?
    
    init(_ address: String) {
        self.address = address
    }
}
