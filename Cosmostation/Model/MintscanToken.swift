//
//  MintscanToken.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

public class MintscanTokens: Codable {
    var assets: [MintscanToken]?
}


public class MintscanToken: Codable, NSCopying {
    var type: String?
    var chainName: String?
    var name: String?
    var address: String?                //we handle contract address as denom
    var symbol: String?
    var decimals: Int16?
    var description: String?
    var image: String?
    var coinGeckoId: String?
    var wallet_preload: Bool?
    var amount: String?
    
    init(type: String? = nil, chainName: String? = nil, name: String? = nil, address: String? = nil, symbol: String? = nil, decimals: Int16? = nil, description: String? = nil, image: String? = nil, coinGeckoId: String? = nil, wallet_preload: Bool? = nil, amount: String? = nil) {
        self.type = type
        self.chainName = chainName
        self.name = name
        self.address = address
        self.symbol = symbol
        self.decimals = decimals
        self.description = description
        self.image = image
        self.coinGeckoId = coinGeckoId
        self.wallet_preload = wallet_preload
        self.amount = amount
    }
    
    func setAmount(_ rawAmount: String?) {
        self.amount = rawAmount
    }
    
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: amount ?? "0")
    }
    
    func assetImg() -> URL? {
        return URL(string: image ?? "")
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return MintscanToken(type: type, chainName: chainName, name: name, address: address, symbol: symbol, decimals: decimals, description: description, image: image, coinGeckoId: coinGeckoId, wallet_preload: wallet_preload, amount: amount)
    }
}
