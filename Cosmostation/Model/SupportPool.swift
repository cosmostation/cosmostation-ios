//
//  SupportPool.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/12/10.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct SupportPool {
    let type: String
    let id: String
    let adenom: String
    let bdenom: String
    
    init(_ dictionary: [String: String]) {
        self.type = dictionary["type"] ?? ""
        self.id = dictionary["id"] ?? ""
        self.adenom = dictionary["adenom"] ?? ""
        self.bdenom = dictionary["bdenom"] ?? ""
    }
}
