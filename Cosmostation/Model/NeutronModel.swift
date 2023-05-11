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


public struct NeutronSwapPool {
    var id: Int64?
    var chain: String?
    var router_address: String?
    var factory_address: String?
    var contract_address: String?
    var total_share: NSDecimalNumber?
    var pairs =  Array<NeutronSwapPoolPair>()
    
    init(_ dictionary: NSDictionary?) {
        self.id = dictionary?["id"] as? Int64
        self.chain = dictionary?["chain"] as? String
        self.router_address = dictionary?["router_address"] as? String
        self.factory_address = dictionary?["factory_address"] as? String
        self.contract_address = dictionary?["contract_address"] as? String
        if let rawShare = dictionary?["total_share"] as? String {
            self.total_share = NSDecimalNumber(string: rawShare)
        }
        if let rawPairs = dictionary?["pairs"] as? Array<NSDictionary> {
            rawPairs.forEach { rawPair in
                self.pairs.append(NeutronSwapPoolPair.init(rawPair))
            }
        }
    }
}


public struct NeutronSwapPoolPair {
    var type: String?
    var address: String?
    var denom: String?
    var amount: String?
    
    init(_ dictionary: NSDictionary?) {
        self.type = dictionary?["type"] as? String
        self.address = dictionary?["address"] as? String
        self.denom = dictionary?["denom"] as? String
        self.amount = dictionary?["amount"] as? String
    }
}


public struct NeutronOfferAsset {
    var amount: String?
    
    
}

public struct NeutronAskAsset {
    var native_token: NeutronNativeToken?
    var token: NeutronToken?
    
    init(_ nativeToken: String?, _ token: String?) {
        if let nativeToken = nativeToken {
            self.native_token = NeutronNativeToken.init(nativeToken)
        }
        if let token = token {
            self.token = NeutronToken.init(token)
        }
    }
    
    init(_ dictionary: NSDictionary?) {
        if let rawNativeToken = dictionary?["native_token"] as? NSDictionary {
            self.native_token = NeutronNativeToken.init(rawNativeToken)
        }
        if let rawToken = dictionary?["token"] as? NSDictionary {
            self.token = NeutronToken.init(rawToken)
        }
    }
}


public struct NeutronSwapAsset {
    
}


public struct NeutronNativeToken {
    var denom: String?
    init(_ string: String?) {
        self.denom = string
    }
    init(_ dictionary: NSDictionary?) {
        self.denom = dictionary?["denom"] as? String
    }
}

public struct NeutronToken {
    var denom: String?
    init(_ string: String?) {
        self.denom = string
    }
    init(_ dictionary: NSDictionary?) {
        self.denom = dictionary?["denom"] as? String
    }
}
