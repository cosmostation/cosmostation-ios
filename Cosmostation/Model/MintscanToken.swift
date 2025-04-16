//
//  MintscanToken.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct MintscanTokens: Codable {
    var assets: [MintscanToken]?
}

public class MintscanToken: Codable {
    var chainName: String?
    var type: String?
    var address: String?   //we handle contract address as denom
    var name: String?
    var symbol: String?
    var description: String?
    var decimals: Int16?
    var image: String?
    var coinGeckoId: String?
    var wallet_preload: Bool?
    var ibc_info: MintscanAssetIbcInfo?
    var amount: String?
    
    func setAmount(_ rawAmount: String) {
        self.amount = rawAmount
    }
    
    func getAmount() -> NSDecimalNumber {
        return NSDecimalNumber.init(string: amount ?? "0")
    }
    
    func assetImg() -> URL? {
        return URL(string: image ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case chainName
        case chain
        case type
        case address
        case contract
        case name
        case symbol
        case description
        case decimals
        case image
        case coinGeckoId
        case wallet_preload
        case ibc_info
        case amount
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.chainName = try container.decodeIfPresent(String.self, forKey: .chainName) ?? container.decodeIfPresent(String.self, forKey: .chain)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.address = try container.decodeIfPresent(String.self, forKey: .address) ?? container.decodeIfPresent(String.self, forKey: .contract)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.decimals = try container.decodeIfPresent(Int16.self, forKey: .decimals)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.coinGeckoId = try container.decodeIfPresent(String.self, forKey: .coinGeckoId)
        self.wallet_preload = try container.decodeIfPresent(Bool.self, forKey: .wallet_preload)
        self.ibc_info = try container.decodeIfPresent(MintscanAssetIbcInfo.self, forKey: .ibc_info)
        self.amount = try container.decodeIfPresent(String.self, forKey: .amount)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(chainName, forKey: .chainName)
        try container.encodeIfPresent(chainName, forKey: .chain)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(address, forKey: .contract)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(symbol, forKey: .symbol)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(decimals, forKey: .decimals)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(coinGeckoId, forKey: .coinGeckoId)
        try container.encodeIfPresent(wallet_preload, forKey: .wallet_preload)
        try container.encodeIfPresent(ibc_info, forKey: .ibc_info)
        try container.encodeIfPresent(amount, forKey: .amount)
    }
}



