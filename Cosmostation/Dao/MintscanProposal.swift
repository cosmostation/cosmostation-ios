//
//  MintscanProposal.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/03/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


public struct MintscanProposal {
    
    var id: UInt64?
    var title: String?
    var description: String?
    var proposal_type: String?
    var proposal_status: String?
    var voting_start_time: String?
    var voting_end_time: String?
    var is_expedited = false
    var yes: NSDecimalNumber = NSDecimalNumber.zero
    var abstain: NSDecimalNumber = NSDecimalNumber.zero
    var no: NSDecimalNumber = NSDecimalNumber.zero
    var no_with_veto: NSDecimalNumber = NSDecimalNumber.zero
    
    init(_ json: JSON?) {
        self.id = json?["id"].uInt64Value
        self.title = json?["title"].stringValue
        self.description = json?["description"].stringValue
        self.proposal_type = json?["proposal_type"].stringValue
        self.proposal_status = json?["proposal_status"].stringValue
        self.voting_start_time = json?["voting_start_time"].stringValue
        self.voting_end_time = json?["voting_end_time"].stringValue
        self.is_expedited = json?["is_expedited"].boolValue ?? false
        
        if let rawYes = json?["yes"].stringValue {
            self.yes = NSDecimalNumber.init(string: rawYes)
        }
        if let rawAbstain = json?["abstain"].stringValue {
            self.abstain = NSDecimalNumber.init(string: rawAbstain)
        }
        if let rawNo = json?["no"].stringValue {
            self.no = NSDecimalNumber.init(string: rawNo)
        }
        if let rawNowithVeto = json?["no_with_veto"].stringValue {
            self.no_with_veto = NSDecimalNumber.init(string: rawNowithVeto)
        }
    }
    
    public func getSum() ->NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        sum = sum.adding(yes)
        sum = sum.adding(abstain)
        sum = sum.adding(no)
        sum = sum.adding(no_with_veto)
        return sum
    }
    
    public func isVotingPeriod() -> Bool {
        if (proposal_status!.localizedCaseInsensitiveContains("VOTING")) {
            return true
        }
        return false
    }
    
    public func isScam() -> Bool {
        if (yes == NSDecimalNumber.zero || getSum() == NSDecimalNumber.zero) {
            return true
        }
        if (yes.dividing(by: getSum()).compare(NSDecimalNumber(string: "0.1")).rawValue > 0) {
            return false
        }
        return true
    }
    
    func onProposalStatusTxt() -> String {
        if (proposal_status?.localizedCaseInsensitiveContains("DEPOSIT") == true) {
            return "DepositPeriod"
        } else if (proposal_status?.localizedCaseInsensitiveContains("VOTING") == true) {
            return "VotingPeriod"
        } else if (proposal_status?.localizedCaseInsensitiveContains("PASSED") == true) {
            return "Passed"
        } else if (proposal_status?.localizedCaseInsensitiveContains("REJECTED") == true) {
            return "Rejected"
        } else if (proposal_status?.localizedCaseInsensitiveContains("FAILED") == true) {
            return "Failed"
        }
        return "unKnown"
    }
    
    func onProposalStatusImg() -> UIImage? {
        if (proposal_status?.localizedCaseInsensitiveContains("DEPOSIT") == true) {
            return UIImage.init(named: "ImgGovDoposit")
        } else if (proposal_status?.localizedCaseInsensitiveContains("VOTING") == true) {
            return UIImage.init(named: "ImgGovVoting")
        } else if (proposal_status?.localizedCaseInsensitiveContains("PASSED") == true) {
            return UIImage.init(named: "ImgGovPassed")
        } else if (proposal_status?.localizedCaseInsensitiveContains("REJECTED") == true) {
            return UIImage.init(named: "ImgGovRejected")
        }
        return UIImage.init(named: "ImgGovFailed")
    }
    
    var toVoteOption: Cosmos_Gov_V1beta1_VoteOption?
}
