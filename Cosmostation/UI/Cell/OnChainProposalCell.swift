//
//  OnChainProposalCell.swift
//  Cosmostation
//
//  Created by 차소민 on 11/6/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class OnChainProposalCell: UITableViewCell {
    
    @IBOutlet weak var rootView: CardViewCell!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var selectSwitch: UISwitch!
    
    var actionToggle: ((Bool) -> Void)? = nil

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
        statusImg.isHidden = true
        statusLabel.isHidden = true
    }
    
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn)
    }

        
    func onBindProposal(_ proposal: MintscanProposal, _ toVote: [UInt64]) {
        idLabel.text = "# ".appending(String(proposal.id!) + ".")
        titleLabel.text = proposal.title
        
        if (proposal.isVotingPeriod()) {
            selectSwitch.isHidden = false
            timeLabel.text = WDP.dpFullTime(proposal.voting_end_time).appending(" ").appending(WDP.dpTimeGap(proposal.voting_end_time))
            timeLabel.isHidden = false
            selectSwitch.isOn = toVote.contains(proposal.id!)

        } else {
            selectSwitch.isHidden = true
            statusLabel.text = proposal.onProposalStatusTxt().uppercased()
            statusImg.image = proposal.onProposalStatusImg()
            statusLabel.isHidden = false
            statusImg.isHidden = false
        }
    }
}
