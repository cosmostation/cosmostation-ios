//
//  VoteThreeItemsCell.swift
//  Cosmostation
//
//  Created by 차소민 on 12/13/24.
//  Copyright © 2024 wannabit. All rights reserved.
//

import UIKit

class VoteThreeItemsCell: UITableViewCell {
    
    @IBOutlet weak var rootView: FixCardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    @IBOutlet weak var abstainBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        yesBtn.tag = 0
        noBtn.tag = 1
        abstainBtn.tag = 3
        yesBtn.setImage(nil, for: .normal)
        noBtn.setImage(nil, for: .normal)
        abstainBtn.setImage(nil, for: .normal)
        yesBtn.layer.borderWidth = 1
        noBtn.layer.borderWidth = 1
        abstainBtn.layer.borderWidth = 1
        yesBtn.layer.borderColor = UIColor.color05.cgColor
        noBtn.layer.borderColor = UIColor.color05.cgColor
        abstainBtn.layer.borderColor = UIColor.color05.cgColor
    }
    
    override func prepareForReuse() {
        yesBtn.setImage(nil, for: .normal)
        noBtn.setImage(nil, for: .normal)
        abstainBtn.setImage(nil, for: .normal)
        yesBtn.layer.borderColor = UIColor.color05.cgColor
        noBtn.layer.borderColor = UIColor.color05.cgColor
        abstainBtn.layer.borderColor = UIColor.color05.cgColor
    }
    
    var actionToggle: ((Int) -> Void)? = nil
    @IBAction func onClickVote(_ sender: UIButton) {
        actionToggle?(sender.tag)
    }
    
    
    func onBindVote(_ proposal: MintscanProposal) {
        let title = "# ".appending(String(proposal.id!)).appending("  ").appending(proposal.title ?? "")
        titleLabel.text = title
        timeLabel.text = WDP.dpTime(proposal.voting_end_time).appending(" ").appending(WDP.dpTimeGap(proposal.voting_end_time))
        
        if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.yes) {
            yesBtn.setImage(UIImage(named: "iconCheck"), for: .normal)
            yesBtn.layer.borderColor = UIColor.white.cgColor
            
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.no) {
            noBtn.setImage(UIImage(named: "iconCheck"), for: .normal)
            noBtn.layer.borderColor = UIColor.white.cgColor
                        
        } else if (proposal.toVoteOption == Cosmos_Gov_V1beta1_VoteOption.abstain) {
            abstainBtn.setImage(UIImage(named: "iconCheck"), for: .normal)
            abstainBtn.layer.borderColor = UIColor.white.cgColor
            
        }
    }
}
