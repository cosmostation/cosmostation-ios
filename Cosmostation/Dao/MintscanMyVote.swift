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


public struct MintscanDaoVote {
    var id: Int64?
    var chain: String?
    var chain_id: String?
    var height: Int64?
    var tx_hash: String?
    var contract_address: String?
    var address: String?
    var proposal_id: Int64?
    var power: String?
    var option: String?
    var voted_at: String?
    
    init(_ dictionary: NSDictionary?) {
        self.id = dictionary?["id"] as? Int64
        self.chain = dictionary?["chain"] as? String
        self.chain_id = dictionary?["chain_id"] as? String
        self.height = dictionary?["height"] as? Int64
        self.tx_hash = dictionary?["tx_hash"] as? String
        self.contract_address = dictionary?["contract_address"] as? String
        self.address = dictionary?["address"] as? String
        self.proposal_id = dictionary?["proposal_id"] as? Int64
        self.power = dictionary?["power"] as? String
        self.option = dictionary?["option"] as? String
        self.voted_at = dictionary?["voted_at"] as? String
    }
}
