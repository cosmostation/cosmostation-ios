//
//  VoteCell.swift
//  Cosmostation
//
//  Created by yongjoo jung on 2023/10/03.
//  Copyright © 2023 wannabit. All rights reserved.
//

import UIKit

class VoteCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var yesSwitch: UISwitch!
    @IBOutlet weak var noSwitch: UISwitch!
    @IBOutlet weak var vetoSwitch: UISwitch!
    @IBOutlet weak var abstainSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        yesSwitch.tag = 0
        yesSwitch.isOn = false
        noSwitch.tag = 1
        noSwitch.isOn = false
        vetoSwitch.tag = 2
        vetoSwitch.isOn = false
        abstainSwitch.tag = 3
        abstainSwitch.isOn = false
    }
    
    override func prepareForReuse() {
        yesSwitch.isOn = false
        noSwitch.isOn = false
        vetoSwitch.isOn = false
        abstainSwitch.isOn = false
    }
    
    var actionToggle: ((Bool, Int) -> Void)? = nil
    @IBAction func onToggle(_ sender: UISwitch) {
        actionToggle?(sender.isOn, sender.tag)
    }
    
    
    func onBindVote(_ proposal: MintscanProposal) {
        let title = "# ".appending(String(proposal.id!)).appending("  ").appending(proposal.title ?? "")
        titleLabel.text = title
        if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.yes) {
            yesSwitch.isOn = true
            
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.no) {
            noSwitch.isOn = true
            
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.noWithVeto) {
            vetoSwitch.isOn = true
            
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.abstain) {
            abstainSwitch.isOn = true
            
        }
    }
}
