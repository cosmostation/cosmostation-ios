//
//  SupportPool.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/12/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct SupportPool {
    var id: String!
    var adenom: String!
    var bdenom: String!
    
    init(_ dictionary: NSDictionary?) {
        self.id = dictionary?["id"] as? String ?? ""
        self.adenom = dictionary?["adenom"] as? String ?? ""
        self.bdenom = dictionary?["bdenom"] as? String ?? ""
    }
}
