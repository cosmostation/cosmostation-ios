//
//  CosmosProposalCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit
import SwiftyJSON

class CosmosProposalCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var myVoteImg: UIImageView!
    @IBOutlet weak var myVoteNumber: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var expectedImg: UIImageView!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var selectSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        selectSwitch.isHidden = true
        selectSwitch.isOn = false
    }
    
    override func prepareForReuse() {
        selectSwitch.isHidden = true
        selectSwitch.isOn = false
        timeLabel.isHidden = true
        timeLabel.text = ""
        myVoteNumber.isHidden = true
        expectedImg.isHidden = true
        statusImg.isHidden = true
        statusLabel.isHidden = true
    }
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func onBindProposal(_ proposal: MintscanProposal, _ myVotes: [MintscanMyVotes], _ toVote: [UInt64]) {
        idLabel.text = "# ".appending(String(proposal.id!) + ".")
        titleLabel.text = proposal.title
        
        if (proposal.isVotingPeriod()) {
            selectSwitch.isHidden = false
            timeLabel.text = WDP.dpFullTime(proposal.voting_end_time).appending(" ").appending(WDP.dpTimeGap(proposal.voting_end_time))
            timeLabel.isHidden = false
            expectedImg.isHidden = !proposal.is_expedited
            selectSwitch.isOn = toVote.contains(proposal.id!)
            
        } else {
            selectSwitch.isHidden = true
            statusLabel.text = proposal.onProposalStatusTxt().uppercased()
            statusImg.image = proposal.onProposalStatusImg()
            statusLabel.isHidden = false
            statusImg.isHidden = false
            expectedImg.isHidden = !proposal.is_expedited
        }
        
        
        if let rawVote = myVotes.filter({ $0.proposal_id == proposal.id }).first {
            if (rawVote.votes.count > 1) {
                self.myVoteImg.image = UIImage.init(named: "imgMyVoteWeight")
            } else {
                let myVote = rawVote.votes[0]
                if (myVote.option?.uppercased().contains("YES") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgMyVoteYes")
                    return
                } else if (myVote.option?.uppercased().contains("VETO") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgMyVoteVeto")
                    return
                } else if (myVote.option?.uppercased().contains("NO") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgMyVoteNo")
                    return
                } else if (myVote.option?.uppercased().contains("ABSTAIN") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgMyVoteAbstain")
                    return
                } else {
                    self.myVoteImg.image = nil
                }
            }
        } else {
            self.myVoteImg.image = UIImage.init(named: "imgMyVoteNone")
        }
    }
    
    func onBindNeutronDao(_ module: JSON?, _ proposal: JSON, _ myVotes: [JSON]?, _ toVote: [Int64]) {
        guard let module = module else {
            return
        }
        let id = proposal["id"].int64Value
        let contents = proposal["proposal"]
        idLabel.text = "# ".appending(String(id) + ".")
        titleLabel.text = contents["title"].stringValue
        
        let status = contents["status"].stringValue.lowercased()
        if (status == "open") {
            selectSwitch.isHidden = false
            let expirationTime = contents["expiration"]["at_time"].int64Value
            if (expirationTime > 0) {
                let time = expirationTime / 1000000
                timeLabel.text = WDP.dpFullTime(time).appending(" ").appending(WDP.dpTimeGap(time))
            }
            let expirationHeight = contents["expiration"]["at_height"].int64Value
            if (expirationHeight > 0) {
                timeLabel.text = "Expiration at : " + String(expirationHeight) + " Block"
            }
            timeLabel.isHidden = false
            selectSwitch.isOn = toVote.contains(id)
            
        } else {
            selectSwitch.isHidden = true
            if (status == "passed" || status == "executed") {
                statusImg.image = UIImage.init(named: "ImgGovPassed")
            } else if (status == "rejected" || status == "failed" || status == "execution_failed") {
                statusImg.image = UIImage.init(named: "ImgGovRejected")
            }
            statusImg.isHidden = false
            statusLabel.text = status.uppercased()
            statusLabel.isHidden = false
            
        }
        
        if let myVote = myVotes?.filter({$0["contract_address"].stringValue == module["address"].stringValue && $0["proposal_id"].int64Value == id }).first {
            let myOption = myVote["option"].stringValue.lowercased()
            if (myOption == "yes") {
                myVoteImg.image = UIImage.init(named: "imgMyVoteYes")
                myVoteImg.isHidden = false
                return
                
            } else if (myOption == "no") {
                myVoteImg.image = UIImage.init(named: "imgMyVoteNo")
                myVoteImg.isHidden = false
                return
                
            } else if (myOption == "abstain") {
                myVoteImg.image = UIImage.init(named: "imgMyVoteAbstain")
                myVoteImg.isHidden = false
                return
                
            } else {
                myVoteNumber.text = "Option " + myOption
                myVoteNumber.isHidden = false
                myVoteImg.isHidden = true
                return
            }
            
        } else {
            myVoteImg.image = UIImage.init(named: "imgMyVoteNone")
            myVoteImg.isHidden = false
        }
        
    }
}
