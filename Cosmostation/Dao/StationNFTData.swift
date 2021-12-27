//
//  StationNFTData.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/26.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation

public struct StationNFTData : Codable  {
    var denom_id: String?
    var issuerAddr: String?
    var name: String?
    var description: String?
    var imgurl: String?
    
    init(_ name: String, _ description: String, _ imgurl: String, _ denom_id: String, _ issuerAddr: String) {
        self.denom_id = denom_id
        self.description = description
        self.imgurl = imgurl
        self.denom_id = denom_id
        self.issuerAddr = issuerAddr
    }
}
