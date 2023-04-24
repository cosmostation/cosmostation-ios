//
//  NeutronModel.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/04/24.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON


public struct NeutronVault {
    var name: String?
    var description: String?
    var address: String?
    var owner: String?
    var manager: String?
    var denom: String?
    
    init(_ dictionary: NSDictionary?) {
        self.name = dictionary?["name"] as? String
        self.description = dictionary?["description"] as? String
        self.address = dictionary?["address"] as? String
        self.owner = dictionary?["owner"] as? String
        self.manager = dictionary?["manager"] as? String
        self.denom = dictionary?["denom"] as? String
    }
}


public struct NeutronDao {
    var name: String?
    var description: String?
    var address: String?
    var data: JSON?
    
    init(_ dictionary: NSDictionary?) {
        self.name = dictionary?["name"] as? String
        self.description = dictionary?["description"] as? String
        self.address = dictionary?["address"] as? String
        self.data = dictionary?["data"] as? JSON
    }
}
