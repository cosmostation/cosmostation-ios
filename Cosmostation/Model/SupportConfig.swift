//
//  SupportConfig.swift
//  Cosmostation
//
//  Created by 권혁준 on 2023/07/04.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation

public struct SupportConfig {
    var supportChainNames: Array<String>?
    var supportChainIds: Array<String>?
    var customChains = Array<CustomChain>()
    
    init(_ dictionary: NSDictionary?) {
        if let rawSupportChainNames = dictionary?["supportChainNames"] as? Array<String> {
            self.supportChainNames = rawSupportChainNames
        }
        if let rawSupportChainIds = dictionary?["supportChainIds"] as? Array<String> {
            self.supportChainIds = rawSupportChainIds
        }
        if let rawCustomChains = dictionary?["customChains"] as? Array<NSDictionary> {
            rawCustomChains.forEach { rawCustomChain in
                self.customChains.append(CustomChain.init(rawCustomChain))
            }
        }
    }
}

public struct CustomChain {
    var chainId: String?
    var denom: String?
    var prefix: String?
    
    init(_ dictionary: NSDictionary?) {
        self.chainId = dictionary?["chainId"] as? String
        self.denom = dictionary?["denom"] as? String
        self.prefix = dictionary?["prefix"] as? String
    }
}
