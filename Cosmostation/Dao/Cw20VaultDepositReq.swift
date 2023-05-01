//
//  Cw20VaultDeposit.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/24.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation


public struct Cw20VaultDepositReq : Codable {
    var voting_power_at_height: VaultDepositReq?
    
    init(_ address: String) {
        self.voting_power_at_height = VaultDepositReq.init(address)
    }
    
    func getEncode() -> Data {
        let jsonEncoder = JSONEncoder()
        return try! jsonEncoder.encode(self)
    }
}

public struct VaultDepositReq : Codable {
    var address: String?
    
    init(_ address: String) {
        self.address = address
    }
}
