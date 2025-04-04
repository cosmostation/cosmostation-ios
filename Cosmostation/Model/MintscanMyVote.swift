//
//  MintscanMyVote.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/07/18.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct MintscanMyVotes {
    var proposal_id: UInt64?
    var votes = Array<MintscanMyVote>()
    
    init(_ json: JSON?) {
        self.proposal_id = json?["proposal_id"].uInt64Value
        if let votes = json?["votes"].array {
            votes.forEach({ vote in
                self.votes.append(MintscanMyVote(vote))
            })
        } else {
            votes = [MintscanMyVote(json)]
        }
    }
    
    init(_ vote: Cosmos_Gov_V1_Vote?) {
        proposal_id = vote?.proposalID
        votes = [MintscanMyVote(vote)]
    }
 
    init(_ vote: Cosmos_Gov_V1beta1_Vote?) {
        proposal_id = vote?.proposalID
        votes = [MintscanMyVote(vote)]
    }
}

public struct MintscanMyVote {
    var voter: String?
    var option: String?
    var tx_hash: String?
    var timestamp: String?
    var answer: String?
    
    var options = ["unspecified", "yes", "abstain", "no", "noWithVeto"]
    
    init(_ json: JSON?) {
        self.voter = json?["voter"].stringValue
        self.option = json?["option"].string ?? json?["options"].array?.first?["option"].string
        self.tx_hash = json?["tx_hash"].string ?? ""
        self.timestamp = json?["timestamp"].string ?? ""
        self.answer = json?["answer"].string ?? ""
    }
    
    init(_ vote: Cosmos_Gov_V1_Vote?) {
        self.voter = vote?.voter
        self.option = options[vote?.options.first?.option.rawValue ?? 0]
        self.tx_hash = ""
        self.timestamp = ""
        self.answer = ""
    }
    
    init(_ vote: Cosmos_Gov_V1beta1_Vote?) {
        self.voter = vote?.voter
        self.option = options[vote?.options.first?.option.rawValue ?? 0]
        self.tx_hash = ""
        self.timestamp = ""
        self.answer = ""
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
