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
    var dao_uri: String?
    var address: String?
    var voting_module: String?
    var proposal_modules = Array<NeutronProposalModule>()
    
    init(_ dictionary: NSDictionary?) {
        self.name = dictionary?["name"] as? String
        self.description = dictionary?["description"] as? String
        self.dao_uri = dictionary?["dao_uri"] as? String
        self.address = dictionary?["address"] as? String
        if let rawModules = dictionary?["proposal_modules"] as? Array<NSDictionary> {
            rawModules.forEach { rawModule in
                self.proposal_modules.append(NeutronProposalModule(rawModule))
            }
        }
    }
}

public struct NeutronProposalModule {
    var name: String?
    var description: String?
    var address: String?
    var prefix: String?
    var status: Bool?
    
    init(_ dictionary: NSDictionary?) {
        self.name = dictionary?["name"] as? String
        self.description = dictionary?["description"] as? String
        self.address = dictionary?["address"] as? String
        self.prefix = dictionary?["prefix"] as? String
        if let rawStatus = dictionary?["status"] as? String {
            if (rawStatus == "Enabled") { self.status = true }
        }
    }
    
}
