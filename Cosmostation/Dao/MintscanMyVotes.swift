//
//  MintscanMyVotes.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/08/01.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct MintscanMyVotes {
    var proposal_id: UInt?
    var votes = Array<MintscanMyVote>()
    
    init(_ dictionary: NSDictionary?) {
        self.proposal_id = dictionary?["proposal_id"] as? UInt
        if let rawVotes = dictionary?["votes"] as? Array<NSDictionary> {
            rawVotes.forEach { rawVote in
                votes.append(MintscanMyVote.init(rawVote))
            }
        }
    }
    
}
