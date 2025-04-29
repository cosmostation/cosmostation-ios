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
import SwiftProtobuf

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
        let id = json?["id"].uInt64Value
        self.id = id == 0 ? json?["proposal_id"].uInt64Value : id
        let title = json?["title"].stringValue
        self.title = title == "" ? json?["messages"].arrayValue.first?["content"]["title"].string ?? json?["content"]["title"].string ?? "" : title
        if self.title == "" {
            if let range = json?["metadata"].stringValue.range(of: #"(?<="title":")[^"]*"#, options: .regularExpression) {
                self.title = String((json?["metadata"].stringValue[range]) ?? "")
            } else {
                self.title = json?["messages"].arrayValue.first?["@type"].string?.components(separatedBy: ".").last ?? json?["content"]["@type"].string?.components(separatedBy: ".").last ?? ""
            }
        }
        
        let description = json?["description"].string ?? json?["summary"].stringValue
        self.description = description == "" ? json?["messages"].arrayValue.first?["content"]["description"].string ?? json?["content"]["description"].string : description
        self.proposal_type = json?["proposal_type"].string
        self.proposal_status = json?["proposal_status"].string ?? json?["status"].string
        self.voting_start_time = json?["voting_start_time"].stringValue
        self.voting_end_time = json?["voting_end_time"].stringValue
        self.is_expedited = json?["is_expedited"].boolValue ?? false
        
        if let rawYes = json?["yes"].stringValue, !rawYes.isEmpty {
            self.yes = NSDecimalNumber.init(string: rawYes)
            
        } else if let rawYes = json?["final_tally_result"]["yes_count"].stringValue, !rawYes.isEmpty {
            self.yes = NSDecimalNumber.init(string: rawYes)
        }
        
        if let rawAbstain = json?["abstain"].stringValue, !rawAbstain.isEmpty {
            self.abstain = NSDecimalNumber.init(string: rawAbstain)
        } else if let rawAbstain = json?["final_tally_result"]["abstain_count"].stringValue, !rawAbstain.isEmpty {
            self.abstain = NSDecimalNumber.init(string: rawAbstain)
        }
        
        if let rawNo = json?["no"].stringValue, !rawNo.isEmpty {
            self.no = NSDecimalNumber.init(string: rawNo)
        } else if let rawNo = json?["final_tally_result"]["no_count"].stringValue, !rawNo.isEmpty {
            self.no = NSDecimalNumber.init(string: rawNo)
        }
        
        if let rawNowithVeto = json?["no_with_veto"].stringValue, !rawNowithVeto.isEmpty {
            self.no_with_veto = NSDecimalNumber.init(string: rawNowithVeto)
        } else if let rawNowithVeto = json?["final_tally_result"]["no_with_veto_count"].stringValue, !rawNowithVeto.isEmpty {
            self.no_with_veto = NSDecimalNumber.init(string: rawNowithVeto)
        }
    }
    
    init(_ data: Cosmos_Gov_V1_Proposal?) {
        self.id = data?.id
        self.title = data?.title ?? ""
        if self.title == "" {
            if let range = data?.metadata.range(of: #"(?<="title":")[^"]*"#, options: .regularExpression) {
                self.title = String((data?.metadata[range]) ?? "")
            } else {
                self.title = data?.messages.first?.typeURL.components(separatedBy: ".").last
            }
        }

        self.description = data?.summary
        
        switch data?.status {
        case .unspecified:
            self.proposal_status = "unspecified"
        case .depositPeriod:
            self.proposal_status = "depositPeriod"
        case .votingPeriod:
            self.proposal_status = "votingPeriod"
        case .passed:
            self.proposal_status = "passed"
        case .rejected:
            self.proposal_status = "rejected"
        case .failed:
            self.proposal_status = "failed"
        case .UNRECOGNIZED(_):
            self.proposal_status = nil
        case nil:
            self.proposal_status = nil
        }
        
        self.voting_start_time = data?.votingStartTime.timestampToString()
        self.voting_end_time = data?.votingEndTime.timestampToString()
    }
    
    init(_ data: Cosmos_Gov_V1beta1_Proposal?) {
        self.id = data?.proposalID
        self.title = data?.content.typeURL.components(separatedBy: ".").last
        self.description = JSON(data?.content.value.prettyJson as Any)["description"].string
        
        switch data?.status {
        case .unspecified:
            self.proposal_status = "unspecified"
        case .depositPeriod:
            self.proposal_status = "depositPeriod"
        case .votingPeriod:
            self.proposal_status = "votingPeriod"
        case .passed:
            self.proposal_status = "passed"
        case .rejected:
            self.proposal_status = "rejected"
        case .failed:
            self.proposal_status = "failed"
        case .UNRECOGNIZED(_):
            self.proposal_status = nil
        case nil:
            self.proposal_status = nil
        }
        
        self.voting_start_time = data?.votingStartTime.timestampToString()
        self.voting_end_time = data?.votingEndTime.timestampToString()
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
        if (proposal_status!.uppercased().localizedCaseInsensitiveContains("VOTING")) {
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

extension Google_Protobuf_Timestamp {
    func timestampToString() -> String? {
        let date = Date(timeIntervalSince1970: TimeInterval(self.seconds))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        return dateFormatter.string(from: date)
    }
}
