//
//  MintscanToken.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public class MintscanToken {
    var id: Int64 = -1
    var chain: String = ""
    var contract_address: String = ""
    var denom: String = ""
    var decimal: Int16 = 6
    var display: Int16 = -1
    var logo: String = ""
    var default_show: Bool = false
    var total_supply: Int64 = 0
    var coingecko_id: String = ""
    var amount: String = "0"
    
    init(_ dictionary: NSDictionary?) {
        self.id = dictionary?["id"] as? Int64 ?? -1
        self.chain = dictionary?["chain"] as? String ?? ""
        self.contract_address = dictionary?["contract_address"] as? String ?? ""
        self.denom = dictionary?["denom"] as? String ?? ""
        self.decimal = dictionary?["decimal"] as? Int16 ?? 6
        self.display = dictionary?["display"] as? Int16 ?? -1
        self.logo = dictionary?["logo"] as? String ?? ""
        self.default_show = dictionary?["default"] as? Bool ?? false
        self.total_supply = dictionary?["total_supply"] as? Int64 ?? -1
        self.coingecko_id = dictionary?["coingecko_id"] as? String ?? ""
    }
    
    func setAmount(_ rawAmount: String) {
        self.amount = rawAmount
    }
    
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: amount)
    }
    
    func assetImg() -> URL? {
        if (logo.starts(with: "https://")) {
            return URL(string: logo)
        } else {
            return URL(string: AssetBase + logo)
        }
    }
    
}
