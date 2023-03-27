//
//  MintscanV1Proposal.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/03/27.
//  Copyright © 2023 wannabit. All rights reserved.
//

import Foundation
import UIKit


public struct MintscanV1Proposal {
    var id: UInt?
    var title: String?
    var description: String?
    var proposal_type: String?
    var proposal_status: String?
    var voting_start_time: String?
    var voting_end_time: String?
    var yes: NSDecimalNumber = NSDecimalNumber.zero
    var abstain: NSDecimalNumber = NSDecimalNumber.zero
    var no: NSDecimalNumber = NSDecimalNumber.zero
    var no_with_veto: NSDecimalNumber = NSDecimalNumber.zero
    
    
    init(_ dictionary: NSDictionary?) {
        if let rawId = dictionary?["id"] as? String {
            self.id = UInt(rawId)
        }
        self.title = dictionary?["title"] as? String
        self.description = dictionary?["description"] as? String
        self.proposal_type = dictionary?["proposal_type"] as? String
        self.proposal_status = dictionary?["proposal_status"] as? String
        self.voting_start_time = dictionary?["voting_start_time"] as? String
        self.voting_end_time = dictionary?["voting_end_time"] as? String
        if let rawYes = dictionary?["yes"] as? String {
            self.yes = NSDecimalNumber.init(string: rawYes)
        }
        if let rawAbstain = dictionary?["abstain"] as? String {
            self.abstain = NSDecimalNumber.init(string: rawAbstain)
        }
        if let rawNo = dictionary?["no"] as? String {
            self.no = NSDecimalNumber.init(string: rawNo)
        }
        if let rawNowithVeto = dictionary?["no_with_veto"] as? String {
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
}
