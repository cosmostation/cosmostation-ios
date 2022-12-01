//
//  Price.swift
//  Cosmostation
//
//  Created by 정용주 on 2021/05/17.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation

public struct Price {
    var coinGeckoId: String?
    var denom: String?
    var current_price: Double?
    var market_cap: Double?
    var daily_volume: Double?
    var daily_price_change_in_percent: Double?
    var last_updated: String?
    
    init(_ dictionary: NSDictionary?) {
        self.coinGeckoId = dictionary?["coinGeckoId"] as? String
        self.denom = dictionary?["denom"] as? String
        self.current_price = dictionary?["current_price"] as? Double
        self.market_cap = dictionary?["market_cap"] as? Double
        self.daily_volume = dictionary?["daily_volume"] as? Double
        self.daily_price_change_in_percent = dictionary?["daily_price_change_in_percent"] as? Double
        self.last_updated = dictionary?["last_updated"] as? String
    }
}
