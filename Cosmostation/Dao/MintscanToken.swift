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
    var chainId: String = ""
    var chainName: String = ""
    var address: String = ""            //we handle contract address as denom
    var symbol: String = ""
    var description: String = ""
    var decimals: Int16 = 6
    var display: Int16 = -1
    var image: String = ""
    var coinGeckoId: String = ""
    var default_show: Bool = false
    var total_supply: Int64 = 0
    var amount: String = "0"
    
    init(_ dictionary: NSDictionary?) {
        self.id = dictionary?["id"] as? Int64 ?? -1
        self.chainId = dictionary?["chainId"] as? String ?? ""
        self.chainName = dictionary?["chainName"] as? String ?? ""
        self.address = dictionary?["address"] as? String ?? ""
        self.symbol = dictionary?["symbol"] as? String ?? ""
        self.description = dictionary?["description"] as? String ?? ""
        self.decimals = dictionary?["decimals"] as? Int16 ?? 6
        self.display = dictionary?["display"] as? Int16 ?? -1
        self.image = dictionary?["image"] as? String ?? ""
        self.default_show = dictionary?["default"] as? Bool ?? false
        self.total_supply = dictionary?["total_supply"] as? Int64 ?? -1
        self.coinGeckoId = dictionary?["coinGeckoId"] as? String ?? ""
    }
    
    func setAmount(_ rawAmount: String) {
        self.amount = rawAmount
    }
    
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: amount)
    }
    
    func assetImg() -> URL? {
        return URL(string: ResourceBase + image)
    }
    
}
