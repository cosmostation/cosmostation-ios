//
//  BeraFetcher.swift
//  Cosmostation
//
//  Created by yongjoo jung on 11/27/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation

class BeraFetcher {
    
    var chain: BaseChain!
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    // 24.11.27
    // No custom fetching bera now.
    // https://github.com/berachain/beacon-kit/blob/main/mod/node-api/handlers/beacon/routes.go <- using custom indexer for later
    func fetchBeraData(_ id: Int64) async -> Bool {
        return true
    }
}
