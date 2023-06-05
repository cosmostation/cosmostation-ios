//
//  Cw20NeutronVestingRes.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/05/26.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct Cw20NeutronVestingRes : Codable {
    var allocated_amount: String?
    var withdrawn_amount: String?
    var schedule: VestingSchedule?
}

public struct VestingSchedule : Codable {
    var start_time: Int64?
    var cliff: Int64?
    var duration: Int64?
    
    func getVestingDuration() -> Int64 {
        if (start_time != nil && duration != nil) {
            return (start_time! + duration!) * 1000
        }
        return 0
    }
}
