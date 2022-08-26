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
    var base_denom: String = ""
    var base_type: String = ""
    var dp_denom: String = ""
    var origin_chain: String = ""
    var decimal: Int16 = 6
    var path: String = ""
    var channel: String = ""
    var port: String = ""
    var counter_party: MintscanAssetCounterParty?
    var description: String = ""
    var image: String = ""
    
    init(_ dictionary: NSDictionary?) {
        self.chain = dictionary?["chain"] as? String ?? ""
        self.denom = dictionary?["denom"] as? String ?? ""
        self.type = dictionary?["type"] as? String ?? ""
        self.base_denom = dictionary?["base_denom"] as? String ?? ""
        self.base_type = dictionary?["base_type"] as? String ?? ""
        self.dp_denom = dictionary?["dp_denom"] as? String ?? ""
        self.origin_chain = dictionary?["origin_chain"] as? String ?? ""
        self.decimal = dictionary?["decimal"] as? Int16 ?? 6
        self.path = dictionary?["path"] as? String ?? ""
        self.channel = dictionary?["channel"] as? String ?? ""
        self.port = dictionary?["port"] as? String ?? ""
        if let rawMintscanAssetCounterParty = dictionary?["counter_party"] as? NSDictionary {
            self.counter_party = MintscanAssetCounterParty.init(rawMintscanAssetCounterParty)
        }
        self.description = dictionary?["description"] as? String ?? ""
        self.image = dictionary?["image"] as? String ?? ""
    }
    
    func assetImg() -> URL? {
        let imageurl = AssetBase + image
        return URL(string: imageurl)
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
