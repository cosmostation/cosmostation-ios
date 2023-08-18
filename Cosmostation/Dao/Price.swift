//
//  Price.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/17.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation

public struct Price: Codable {
    var coinGeckoId: String?
    var denom: String?
    var current_price: Double?
    var market_cap: Double?
    var daily_volume: Double?
    var daily_price_change_in_percent: Double?
    var last_updated: String?
}
