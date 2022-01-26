//
//  CertikVote.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2022/01/26.
//  Copyright © 2022 wannabit. All rights reserved.
//

import Foundation

public struct CertikVote {
    var voter: String?
    var proposal_id: String?
    var option: String?
    var options: Array<CertikVoteOption> = Array<CertikVoteOption>()
    
    init(_ dictionary: NSDictionary?) {
        self.voter = dictionary?["voter"] as? String
        self.proposal_id = dictionary?["proposal_id"] as? String
        self.option = dictionary?["option"] as? String
        if let rawOptions = dictionary?["options"] as? Array<NSDictionary> {
            rawOptions.forEach { rawOption in
                self.options.append(CertikVoteOption.init(rawOption))
            }
        }
    }
    
    func getMyOption() -> Cosmos_Gov_V1beta1_VoteOption? {
        if (option?.lowercased().contains("yes") == true) {
            return Cosmos_Gov_V1beta1_VoteOption.yes
        } else if (option?.lowercased().contains("veto") == true) {
            return Cosmos_Gov_V1beta1_VoteOption.noWithVeto
        } else if (option?.lowercased().contains("no") == true) {
            return Cosmos_Gov_V1beta1_VoteOption.no
        } else if (option?.lowercased().contains("abstain") == true) {
            return Cosmos_Gov_V1beta1_VoteOption.abstain
        }
        
        if (options.count > 0) {
            if (options[0].option?.lowercased().contains("yes") == true) {
                return Cosmos_Gov_V1beta1_VoteOption.yes
            } else if (options[0].option?.lowercased().contains("veto") == true) {
                return Cosmos_Gov_V1beta1_VoteOption.noWithVeto
            } else if (options[0].option?.lowercased().contains("no") == true) {
                return Cosmos_Gov_V1beta1_VoteOption.no
            } else if (options[0].option?.lowercased().contains("abstain") == true) {
                return Cosmos_Gov_V1beta1_VoteOption.abstain
            }
        }
        return nil
    }
}


public struct CertikVoteOption {
    var option: String?
    var weight: String?
    
    init(_ dictionary: NSDictionary?) {
        self.option = dictionary?["option"] as? String
        self.weight = dictionary?["weight"] as? String
    }
    
}
