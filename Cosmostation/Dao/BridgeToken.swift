//
//  BridgeToken.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/02/04.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct BridgeToken : Codable {
    var denom: String = ""
    var origin_chain: String?
    var origin_symbol: String?
    var display_symbol: String?
    var decimal: Int16 = 6
    var logo: String = ""
    
    init(_ dictionary: NSDictionary?) {
        self.denom = dictionary?["denom"] as? String ?? ""
        self.origin_chain = dictionary?["origin_chain"] as? String
        self.origin_symbol = dictionary?["origin_symbol"] as? String
        self.display_symbol = dictionary?["display_symbol"] as? String
        self.decimal = dictionary?["decimal"] as? Int16 ?? 6
        self.logo = dictionary?["logo"] as? String ?? ""
    }
    
    func getImgUrl() -> URL {
        if let rawUrl = URL(string: BRIDGE_COIN_IMG_URL + logo) {
            return rawUrl
        }
        return URL(string: "")!
    }
    
}
