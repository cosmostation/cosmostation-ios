//
//  MintscanAsset.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/24.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct MintscanAsset {
    var chain: String = ""
    var denom: String = ""
    var type: String = ""
    var origin_chain: String = ""
    var origin_denom: String = ""
    var origin_type: String = ""
    var symbol: String = ""
    var decimals: Int16 = 6
    var description: String = ""
    var image: String = ""
    var coinGeckoId: String = ""
    
    var enable: Bool = false
    var path: String = ""
    var channel: String = ""
    var port: String = ""
    var counter_party: MintscanAssetCounterParty?
    
    init(_ dictionary: NSDictionary?) {
        self.chain = dictionary?["chain"] as? String ?? ""
        self.denom = dictionary?["denom"] as? String ?? ""
        self.type = dictionary?["type"] as? String ?? ""
        self.origin_chain = dictionary?["origin_chain"] as? String ?? ""
        self.origin_denom = dictionary?["origin_denom"] as? String ?? ""
        self.origin_type = dictionary?["origin_type"] as? String ?? ""
        self.symbol = dictionary?["symbol"] as? String ?? ""
        self.decimals = dictionary?["decimals"] as? Int16 ?? 6
        self.description = dictionary?["description"] as? String ?? ""
        self.image = dictionary?["image"] as? String ?? ""
        self.coinGeckoId = dictionary?["coinGeckoId"] as? String ?? ""
        
        self.enable = dictionary?["enable"] as? Bool ?? false
        self.path = dictionary?["path"] as? String ?? ""
        self.channel = dictionary?["channel"] as? String ?? ""
        self.port = dictionary?["port"] as? String ?? ""
        if let rawMintscanAssetCounterParty = dictionary?["counter_party"] as? NSDictionary {
            self.counter_party = MintscanAssetCounterParty.init(rawMintscanAssetCounterParty)
        }
    }
    
    func assetImg() -> URL? {
        return URL(string: ResourceBase + image)
    }
}

public struct MintscanAssetCounterParty {
    var channel: String?
    var port: String?
    var denom: String?
    
    init(_ dictionary: NSDictionary?) {
        self.channel = dictionary?["channel"] as? String
        self.port = dictionary?["port"] as? String
        self.denom = dictionary?["denom"] as? String
    }
}
