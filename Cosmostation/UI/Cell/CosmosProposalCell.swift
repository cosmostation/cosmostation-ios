//
//  CosmosProposalCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/09/25.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class CosmosProposalCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var myVoteImg: UIImageView!
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
        rootView.setBlur()
    }
    
    override func prepareForReuse() {
        selectSwitch.isHidden = true
        selectSwitch.isOn = false
        timeLabel.isHidden = true
        expectedImg.isHidden = true
        statusImg.isHidden = true
        statusLabel.isHidden = true
        rootView.setBlur()
    }
    
    var actionToggle: ((Bool) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }
    
    func onBindProposal(_ proposal: MintscanProposal, _ myVotes: [MintscanMyVotes], _ toVote: [UInt64]) {
        let title = "# ".appending(String(proposal.id!)).appending("  ").appending(proposal.title ?? "")
        titleLabel.text = title
        
        if (proposal.isVotingPeriod()) {
            selectSwitch.isHidden = false
            timeLabel.text = WDP.dpTime(proposal.voting_end_time).appending(" ").appending(WDP.dpTimeGap(proposal.voting_end_time))
            timeLabel.isHidden = false
            expectedImg.isHidden = !proposal.is_expedited
            selectSwitch.isOn = toVote.contains(proposal.id!)
            
        } else {
            selectSwitch.isHidden = true
            statusLabel.text = proposal.onProposalStatusTxt()
            statusImg.image = proposal.onProposalStatusImg()
            statusLabel.isHidden = false
            statusImg.isHidden = false
            expectedImg.isHidden = !proposal.is_expedited
        }
        
        
        if let rawVote = myVotes.filter({ $0.proposal_id == proposal.id }).first {
            if (rawVote.votes.count > 1) {
                self.myVoteImg.image = UIImage.init(named: "imgVoteWeight")
            } else {
                let myVote = rawVote.votes[0]
                if (myVote.option?.contains("OPTION_YES") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgVoteYes")
                    return
                } else if (myVote.option?.contains("OPTION_NO_WITH_VETO") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgVoteVeto")
                    return
                } else if (myVote.option?.contains("OPTION_NO") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgVoteNo")
                    return
                } else if (myVote.option?.contains("OPTION_ABSTAIN") == true) {
                    self.myVoteImg.image = UIImage.init(named: "imgVoteAbstain")
                    return
                } else {
                    self.myVoteImg.image = nil
                }
            }
        } else {
            self.myVoteImg.image = UIImage.init(named: "imgMyVoteNone")
        }
    }
}
