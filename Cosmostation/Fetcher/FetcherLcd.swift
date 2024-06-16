//
//  FetcherLcd.swift
//  Cosmostation
//
//  Created by yongjoo jung on 6/16/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

class FetcherLcd {
    
    var chain: BaseChain!
    
    var lcdNodeInfo = JSON()
    var lcdAccountInfo = JSON()
    
    init(_ chain: BaseChain) {
        self.chain = chain
    }
    
    func fetchLcdData(_ id: Int64) async -> Bool {
        return false
    }
}
