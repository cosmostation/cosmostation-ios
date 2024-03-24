//
//  Cw721Model.swift
//  Cosmostation
//
//  Created by yongjoo jung on 3/24/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Cw721Model {
    var info = JSON()
    var tokens = [Cw721TokenModel]()
    
    init(_ info: JSON, _ tokens: [Cw721TokenModel]) {
        self.info = info
        self.tokens = tokens
    }
}

struct Cw721TokenModel {
    var tokenId = ""
    var tokenInfo = JSON()
    var tokenDetails = JSON()
    
    init(_ tokenId: String, _ tokenInfo: JSON, _ tokenDetails: JSON) {
        self.tokenId = tokenId
        self.tokenInfo = tokenInfo
        self.tokenDetails = tokenDetails
    }
}
