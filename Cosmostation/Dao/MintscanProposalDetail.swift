//
//  MintscanProposalDetail.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2021/12/01.
//  Copyright © 2021 wannabit. All rights reserved.
//

import Foundation


public struct MintscanProposalDetail {
    var id: String?
    var tx_hash: String?
    var proposer: String?
    var moniker: String?
    var title: String?
    var description: String?
    var proposal_type: String?
    var proposal_status: String?
    var submit_time: String?
    var deposit_end_time: String?
    var voting_start_time: String?
    var voting_end_time: String?
    var voteMeta: MintscanVoteMeta?
    var content: MintscanContent?
    var is_expedited = false
    var messages = Array<MintscanV2Message>()
    
    var myVote: String?
    
    init(_ dictionary: NSDictionary?) {
        self.id = dictionary?["id"] as? String
        self.tx_hash = dictionary?["tx_hash"] as? String
        self.proposer = dictionary?["proposer"] as? String
        self.moniker = dictionary?["moniker"] as? String
        self.title = dictionary?["title"] as? String
        self.description = dictionary?["description"] as? String
        self.proposal_type = dictionary?["proposal_type"] as? String
        self.proposal_status = dictionary?["proposal_status"] as? String
        self.submit_time = dictionary?["submit_time"] as? String
        self.deposit_end_time = dictionary?["deposit_end_time"] as? String
        self.voting_start_time = dictionary?["voting_start_time"] as? String
        self.voting_end_time = dictionary?["voting_end_time"] as? String
        if let rawVoteMeta = dictionary?["voteMeta"] as? NSDictionary  {
            self.voteMeta = MintscanVoteMeta.init(rawVoteMeta)
        }
        if let rawContent = dictionary?["content"] as? NSDictionary  {
            self.content = MintscanContent.init(rawContent)
        }
        self.is_expedited = dictionary?["is_expedited"] as? Bool ?? false
        if let rawMessages = dictionary?["messages"] as? Array<NSDictionary> {
            for rawMessage in rawMessages {
                messages.append(MintscanV2Message.init(rawMessage))
            }
        }
    }
    
    public mutating func setMyVote(_ option: String) {
        self.myVote = option
    }
    
    public func getMyVote() -> String? {
        return self.myVote
    }
    
    public func getValidAmount() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if (voteMeta != nil) {
            sum = sum.adding(voteMeta!.yes_amount)
            sum = sum.adding(voteMeta!.no_amount)
            sum = sum.adding(voteMeta!.abstain_amount)
        }
        return sum
    }
    
    public func getSumAmount() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if (voteMeta != nil) {
            sum = sum.adding(voteMeta!.yes_amount)
            sum = sum.adding(voteMeta!.no_amount)
            sum = sum.adding(voteMeta!.abstain_amount)
            sum = sum.adding(voteMeta!.no_with_veto_amount)
        }
        return sum
    }
    
    public func getYesAmount() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if (voteMeta != nil) {
            sum = sum.adding(voteMeta!.yes_amount)
        }
        return sum
    }
    
    public func getNoAmount() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if (voteMeta != nil) {
            sum = sum.adding(voteMeta!.no_amount)
        }
        return sum
    }
    
    public func getVetoAmount() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if (voteMeta != nil) {
            sum = sum.adding(voteMeta!.no_with_veto_amount)
        }
        return sum
    }
    
    public func getAbstainAmount() -> NSDecimalNumber {
        var sum = NSDecimalNumber.zero
        if (voteMeta != nil) {
            sum = sum.adding(voteMeta!.abstain_amount)
        }
        return sum
    }
    
    public func getYes() -> NSDecimalNumber {
        if (getSumAmount() == NSDecimalNumber.zero || voteMeta == nil) {
            return NSDecimalNumber.zero
        }
        return voteMeta!.yes_amount.multiplying(byPowerOf10: 2).dividing(by: getSumAmount(), withBehavior: WUtils.handler2)
    }
    
    public func getNo() -> NSDecimalNumber {
        if (getSumAmount() == NSDecimalNumber.zero || voteMeta == nil) {
            return NSDecimalNumber.zero
        }
        return voteMeta!.no_amount.multiplying(byPowerOf10: 2).dividing(by: getSumAmount(), withBehavior: WUtils.handler2)
    }
    
    public func getVeto() -> NSDecimalNumber {
        if (getSumAmount() == NSDecimalNumber.zero || voteMeta == nil) {
            return NSDecimalNumber.zero
        }
        return voteMeta!.no_with_veto_amount.multiplying(byPowerOf10: 2).dividing(by: getSumAmount(), withBehavior: WUtils.handler2)
    }
    
    public func getAbstain() -> NSDecimalNumber {
        if (getSumAmount() == NSDecimalNumber.zero || voteMeta == nil) {
            return NSDecimalNumber.zero
        }
        return voteMeta!.abstain_amount.multiplying(byPowerOf10: 2).dividing(by: getSumAmount(), withBehavior: WUtils.handler2)
    }
    
    public func getTurnout() -> NSDecimalNumber {
        guard let param = BaseData.instance.mParam else {
            return NSDecimalNumber.zero
        }
        if (getSumAmount() == NSDecimalNumber.zero || voteMeta == nil) {
            return NSDecimalNumber.zero
        }
        return getSumAmount().multiplying(byPowerOf10: 2).dividing(by: param.getTurnoutBondedAmount(), withBehavior: WUtils.handler2)
    }
    
    public func isScam() -> Bool {
        if (getYesAmount() == NSDecimalNumber.zero || getSumAmount() == NSDecimalNumber.zero) {
            return true
        }
        if (getYesAmount().dividing(by: getSumAmount()).compare(NSDecimalNumber(string: "0.1")).rawValue > 0) {
            return false
        }
        return true
    }
    
    public func getStatus() -> (pass: Bool, reason: String) {
        guard let param = BaseData.instance.mParam else {
            return (false, "")
        }
        let quorum = is_expedited == true ? param.getExpeditedQuorum() : param.getQuorum()
        let threshold = param.getThreshold()
        let vetoThreshold = param.getVetoThreshold()
        let bondedAmount = param.getTurnoutBondedAmount()
        
        if (bondedAmount.multiplying(by: quorum).compare(getSumAmount()).rawValue > 0) {
            return (false, NSLocalizedString("str_vote_reject_by_qourum", comment: ""))
        }
        if (getSumAmount().multiplying(by: vetoThreshold).compare(getVetoAmount()).rawValue < 0) {
            return (false, NSLocalizedString("str_vote_reject_by_veto", comment: ""))
        }
        if (getValidAmount().multiplying(by: threshold).compare(getYesAmount()).rawValue > 0) {
            return (false, NSLocalizedString("str_vote_reject_by_no", comment: ""))
        }
        return (true, NSLocalizedString("str_vote_pass_by_yes", comment: ""))
    }
}

public struct MintscanVoteMeta {
    var yes: String?
    var abstain: String?
    var no: String?
    var no_with_veto: String?
    var yes_amount: NSDecimalNumber = NSDecimalNumber.zero
    var abstain_amount: NSDecimalNumber = NSDecimalNumber.zero
    var no_amount: NSDecimalNumber = NSDecimalNumber.zero
    var no_with_veto_amount: NSDecimalNumber = NSDecimalNumber.zero
    
    init(_ dictionary: NSDictionary?) {
        self.yes = dictionary?["yes"] as? String
        self.abstain = dictionary?["abstain"] as? String
        self.no = dictionary?["no"] as? String
        self.no_with_veto = dictionary?["no_with_veto"] as? String
        if let rawYesAmount = dictionary?["yes_amount"] as? String {
            self.yes_amount = NSDecimalNumber.init(string: rawYesAmount)
        }
        if let rawAbstainAmount = dictionary?["abstain_amount"] as? String {
            self.abstain_amount = NSDecimalNumber.init(string: rawAbstainAmount)
        }
        if let rawNoAmount = dictionary?["no_amount"] as? String {
            self.no_amount = NSDecimalNumber.init(string: rawNoAmount)
        }
        if let rawNowithVetoAmount = dictionary?["no_with_veto_amount"] as? String {
            self.no_with_veto_amount = NSDecimalNumber.init(string: rawNowithVetoAmount)
        }
    }
}

public struct MintscanContent {
    var recipient: String?
    var amount: Array<Coin>?
    
    init(_ dictionary: NSDictionary?) {
        self.recipient = dictionary?["recipient"] as? String ?? ""
        if let rawAmounts = dictionary?["amount"] as? Array<NSDictionary> {
            self.amount = Array<Coin>()
            for rawAmount in rawAmounts {
                self.amount?.append(Coin(rawAmount as! [String : Any]))
            }
        }
        
        //for injective custom
        if let rawProposals = dictionary?["proposals"] as? Array<NSDictionary> {
            if (rawProposals.count > 0) {
                if let rawAmounts = rawProposals[0]["amount"] as? Array<NSDictionary> {
                    self.amount = Array<Coin>()
                    for rawAmount in rawAmounts {
                        self.amount?.append(Coin(rawAmount as! [String : Any]))
                    }
                }
            }
        }
    }
}


public struct MintscanV2Message {
    var type: String?
    var title: String?
    var description: String?
    var requestAmount: Coin?
    var content: MintscanV2Content?
    
    init(_ dictionary: NSDictionary?) {
        self.type = dictionary?["@type"] as? String ?? ""
        self.title = dictionary?["title"] as? String ?? ""
        self.description = dictionary?["description"] as? String ?? ""
        if let rawAmounts = dictionary?["amount"] as? Array<NSDictionary> {
            for rawAmount in rawAmounts {
                requestAmount = Coin.init(rawAmount)
            }
        }
        if let rawContent = dictionary?["content"] as? NSDictionary  {
            self.content = MintscanV2Content.init(rawContent)
        }
        
        if (self.type?.contains("MsgExecLegacyContent") == true && self.content != nil) {
            self.type = self.content?.type
            self.title = self.content?.title
            self.description = self.content?.description
            self.requestAmount = self.content?.requestAmount
        }
    }
}

public struct MintscanV2Content {
    var type: String?
    var title: String?
    var description: String?
    var requestAmount: Coin?
    
    init(_ dictionary: NSDictionary?) {
        self.type = dictionary?["@type"] as? String ?? ""
        self.title = dictionary?["title"] as? String ?? ""
        self.description = dictionary?["description"] as? String ?? ""
        if let rawAmounts = dictionary?["amount"] as? Array<NSDictionary> {
            for rawAmount in rawAmounts {
                requestAmount = Coin.init(rawAmount)
            }
        }
    }
}
