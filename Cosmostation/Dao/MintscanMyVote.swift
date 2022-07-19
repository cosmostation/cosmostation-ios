//
//  MintscanMyVote.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/18.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct MintscanMyVote {
    var voter: String?
    var option: String?
    var tx_hash: String?
    var timestamp: String?
    var answer: String?
    
    init(_ dictionary: NSDictionary?) {
        self.voter = dictionary?["voter"] as? String
        self.option = dictionary?["option"] as? String
        self.tx_hash = dictionary?["tx_hash"] as? String
        self.timestamp = dictionary?["timestamp"] as? String
        self.answer = dictionary?["answer"] as? String
    }
}
